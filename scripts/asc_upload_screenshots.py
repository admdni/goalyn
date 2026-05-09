#!/usr/bin/env python3
"""Upload Goalyn App Store screenshots directly via App Store Connect API.

Pure HTTP API — no fastlane, no altool. Reads PNGs from
fastlane/screenshots/<locale>/IPHONE_69_*.png and uploads them as the
APP_IPHONE_69 display type for the editable App Store version.

Flow:
  1. JWT auth
  2. Resolve app id by bundle id
  3. Find editable appStoreVersion + appStoreVersionLocalizations per locale
  4. For each locale:
       a. Find or create AppScreenshotSet for APP_IPHONE_69
       b. Optionally clear existing screenshots in that set
       c. For each PNG:
            - POST /appScreenshots (reserve, get upload operations)
            - PUT bytes to each upload operation URL
            - PATCH /appScreenshots/{id} with uploaded=true + sourceFileChecksum
"""

import hashlib
import json
import os
import sys
import time
from pathlib import Path
import urllib.request
import urllib.error
import jwt


KEY_ID = os.environ.get('APP_STORE_CONNECT_KEY_IDENTIFIER', '249G24VRT6')
ISSUER_ID = os.environ.get(
    'APP_STORE_CONNECT_ISSUER_ID', '05481e43-1010-4891-b4ec-68befd43ade4'
)
BUNDLE_ID = os.environ.get('BUNDLE_ID', 'com.tanaltay.goalyn.app')
DISPLAY_TYPE = 'APP_IPHONE_69'
LOCALE_DIR = 'zh-Hant'
LOCALE_CODE = 'zh-Hant'

ROOT = Path(__file__).resolve().parent.parent
_LOCAL_KEY = ROOT / f'AuthKey_{KEY_ID}.p8'
_CI_KEY = Path.home() / '.appstoreconnect' / 'private_keys' / f'AuthKey_{KEY_ID}.p8'
KEY_PATH = _CI_KEY if _CI_KEY.exists() else _LOCAL_KEY
SCREENSHOT_DIR = ROOT / 'fastlane' / 'screenshots' / LOCALE_DIR
API = 'https://api.appstoreconnect.apple.com/v1'

_PRIVATE_KEY_ENV = os.environ.get('APP_STORE_CONNECT_PRIVATE_KEY')


def _read_key_text():
    if KEY_PATH.exists():
        return KEY_PATH.read_text()
    if _PRIVATE_KEY_ENV:
        return _PRIVATE_KEY_ENV.replace('\\n', '\n')
    raise RuntimeError(f"No App Store Connect key found at {KEY_PATH} or env")


def make_token():
    return jwt.encode(
        {
            'iss': ISSUER_ID,
            'iat': int(time.time()),
            'exp': int(time.time() + 1200),
            'aud': 'appstoreconnect-v1',
        },
        _read_key_text(),
        algorithm='ES256',
        headers={'kid': KEY_ID, 'typ': 'JWT'},
    )


def req(method, path_or_url, token, body=None, raw_body=None, extra_headers=None):
    headers = {'Authorization': f'Bearer {token}'}
    if extra_headers:
        headers.update(extra_headers)
    data = None
    if body is not None:
        data = json.dumps(body).encode()
        headers['Content-Type'] = 'application/json'
    elif raw_body is not None:
        data = raw_body
    url = path_or_url if path_or_url.startswith('http') else API + path_or_url
    r = urllib.request.Request(url, data=data, method=method, headers=headers)
    try:
        with urllib.request.urlopen(r) as resp:
            text = resp.read().decode() if resp.headers.get('Content-Type', '').startswith('application/') else ''
            return resp.status, json.loads(text) if text else {}
    except urllib.error.HTTPError as e:
        text = e.read().decode()
        try:
            return e.code, json.loads(text)
        except Exception:
            return e.code, {'raw': text}


def put_bytes(url, data, headers):
    r = urllib.request.Request(url, data=data, method='PUT', headers=headers)
    try:
        with urllib.request.urlopen(r) as resp:
            return resp.status, resp.read().decode(errors='ignore')
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode(errors='ignore')


def resolve_app_id(token):
    code, body = req('GET', f'/apps?filter[bundleId]={BUNDLE_ID}', token)
    if code == 200 and body.get('data'):
        return body['data'][0]['id']
    raise RuntimeError(f"App with bundle id {BUNDLE_ID} not found ({code} {body})")


def find_editable_version(token, app_id):
    code, body = req('GET', f'/apps/{app_id}/appStoreVersions?filter[platform]=IOS', token)
    if code != 200:
        return None
    editable_states = {
        'PREPARE_FOR_SUBMISSION', 'METADATA_REJECTED', 'DEVELOPER_REJECTED',
        'WAITING_FOR_REVIEW', 'INVALID_BINARY',
    }
    for v in body.get('data', []):
        if v['attributes']['appStoreState'] in editable_states:
            return v['id']
    return body.get('data', [{}])[0].get('id') if body.get('data') else None


def find_version_localization(token, version_id, locale):
    code, body = req('GET', f'/appStoreVersions/{version_id}/appStoreVersionLocalizations', token)
    if code != 200:
        return None
    for x in body.get('data', []):
        if x['attributes']['locale'] == locale:
            return x['id']
    return None


def find_or_create_screenshot_set(token, version_loc_id, display_type):
    code, body = req('GET', f'/appStoreVersionLocalizations/{version_loc_id}/appScreenshotSets', token)
    if code == 200:
        for x in body.get('data', []):
            if x['attributes']['screenshotDisplayType'] == display_type:
                return x['id']
    code, body = req('POST', '/appScreenshotSets', token, body={
        'data': {
            'type': 'appScreenshotSets',
            'attributes': {'screenshotDisplayType': display_type},
            'relationships': {
                'appStoreVersionLocalization': {
                    'data': {'type': 'appStoreVersionLocalizations', 'id': version_loc_id}
                }
            }
        }
    })
    if code in (200, 201):
        return body['data']['id']
    raise RuntimeError(f"failed to create screenshot set: {code} {body}")


def clear_screenshot_set(token, set_id):
    code, body = req('GET', f'/appScreenshotSets/{set_id}/appScreenshots', token)
    if code != 200:
        return
    for x in body.get('data', []):
        req('DELETE', f"/appScreenshots/{x['id']}", token)
        print(f"  [del] removed existing screenshot {x['id']}")


def upload_one(token, set_id, png_path):
    data = png_path.read_bytes()
    file_name = png_path.name
    file_size = len(data)
    checksum = hashlib.md5(data).hexdigest()

    # 1) Reserve
    code, body = req('POST', '/appScreenshots', token, body={
        'data': {
            'type': 'appScreenshots',
            'attributes': {'fileName': file_name, 'fileSize': file_size},
            'relationships': {
                'appScreenshotSet': {'data': {'type': 'appScreenshotSets', 'id': set_id}}
            }
        }
    })
    if code not in (200, 201):
        print(f"  [reserve {file_name}] FAILED {code}: {json.dumps(body)[:300]}")
        return False
    asset = body['data']
    asset_id = asset['id']
    ops = asset['attributes']['uploadOperations'] or []

    # 2) PUT each upload operation chunk
    for op in ops:
        method = op['method']
        url = op['url']
        offset = op['offset']
        length = op['length']
        chunk = data[offset:offset + length]
        headers = {h['name']: h['value'] for h in op.get('requestHeaders', [])}
        status, _ = put_bytes(url, chunk, headers) if method.upper() == 'PUT' else (0, '')
        if status not in (200, 201, 204):
            print(f"  [upload {file_name}] PUT failed {status}")
            return False

    # 3) Commit
    code, body = req('PATCH', f'/appScreenshots/{asset_id}', token, body={
        'data': {
            'type': 'appScreenshots',
            'id': asset_id,
            'attributes': {'uploaded': True, 'sourceFileChecksum': checksum},
        }
    })
    if code not in (200, 201):
        print(f"  [commit {file_name}] FAILED {code}: {json.dumps(body)[:300]}")
        return False
    print(f"  [ok] {file_name} ({file_size} bytes)")
    return True


def main():
    if not SCREENSHOT_DIR.exists():
        print(f"[skip] no screenshots dir at {SCREENSHOT_DIR}")
        return
    pngs = sorted(SCREENSHOT_DIR.glob('IPHONE_69_*.png'))
    if not pngs:
        print(f"[skip] no IPHONE_69_*.png in {SCREENSHOT_DIR}")
        return

    token = make_token()
    app_id = resolve_app_id(token)
    print(f"[app] id={app_id}")
    version_id = find_editable_version(token, app_id)
    if not version_id:
        print("[skip] no editable App Store version")
        return
    print(f"[version] id={version_id}")
    loc_id = find_version_localization(token, version_id, LOCALE_CODE)
    if not loc_id:
        print(f"[skip] no {LOCALE_CODE} version localization — run asc_upload_metadata.py first")
        return
    print(f"[loc] {LOCALE_CODE} id={loc_id}")

    set_id = find_or_create_screenshot_set(token, loc_id, DISPLAY_TYPE)
    print(f"[set] {DISPLAY_TYPE} id={set_id}")
    clear_screenshot_set(token, set_id)

    ok = 0
    for png in pngs:
        if upload_one(token, set_id, png):
            ok += 1
    print(f"[done] uploaded {ok}/{len(pngs)} screenshots to {LOCALE_CODE}/{DISPLAY_TYPE}")


if __name__ == '__main__':
    main()
