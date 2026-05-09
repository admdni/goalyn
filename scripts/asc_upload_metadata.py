#!/usr/bin/env python3
"""Upload Goalyn App Store metadata directly via App Store Connect API.

Bypasses the Fastlane releaseType bug by writing only to the localization
endpoints (appInfoLocalizations + appStoreVersionLocalizations), never
touching the appStoreVersion resource attributes.
"""

import json
import sys
import time
from pathlib import Path
import urllib.request
import urllib.error
import jwt


KEY_ID = '249G24VRT6'
ISSUER_ID = '05481e43-1010-4891-b4ec-68befd43ade4'
APP_ID = '6767691750'

ROOT = Path(__file__).resolve().parent.parent
KEY_PATH = ROOT / f'AuthKey_{KEY_ID}.p8'
META = ROOT / 'fastlane' / 'metadata'
API = 'https://api.appstoreconnect.apple.com/v1'

# App Store Connect locale codes used by the metadata folder names.
LOCALES = {
    'en-US': 'en-US',
    'zh-Hant': 'zh-Hant',
    'zh-Hans': 'zh-Hans',
}


def make_token():
    return jwt.encode(
        {
            'iss': ISSUER_ID,
            'iat': int(time.time()),
            'exp': int(time.time() + 1200),
            'aud': 'appstoreconnect-v1',
        },
        KEY_PATH.read_text(),
        algorithm='ES256',
        headers={'kid': KEY_ID, 'typ': 'JWT'},
    )


def req(method, path, token, body=None):
    headers = {'Authorization': f'Bearer {token}'}
    data = None
    if body is not None:
        data = json.dumps(body).encode()
        headers['Content-Type'] = 'application/json'
    r = urllib.request.Request(API + path, data=data, method=method, headers=headers)
    try:
        with urllib.request.urlopen(r) as resp:
            text = resp.read().decode()
            return resp.status, json.loads(text) if text else {}
    except urllib.error.HTTPError as e:
        text = e.read().decode()
        try:
            return e.code, json.loads(text)
        except Exception:
            return e.code, {'raw': text}


def read_meta(folder, file):
    p = META / folder / file
    return p.read_text().strip() if p.exists() else None


def get_app_info(token):
    code, body = req('GET', f'/apps/{APP_ID}/appInfos', token)
    if code != 200 or not body.get('data'):
        print(f"[appInfo] failed: {code} {body}")
        sys.exit(1)
    # Latest editable appInfo (state EDITABLE preferred).
    editable = next(
        (x for x in body['data'] if x['attributes']['state'] in ('PREPARE_FOR_SUBMISSION', 'WAITING_FOR_REVIEW', 'DEVELOPER_REJECTED', 'REJECTED')),
        body['data'][0],
    )
    return editable['id']


def list_app_info_localizations(token, app_info_id):
    code, body = req('GET', f'/appInfos/{app_info_id}/appInfoLocalizations', token)
    if code != 200:
        return {}
    return {x['attributes']['locale']: x['id'] for x in body.get('data', [])}


def upsert_app_info_localization(token, app_info_id, existing, locale, name, subtitle):
    if locale in existing:
        loc_id = existing[locale]
        code, body = req('PATCH', f'/appInfoLocalizations/{loc_id}', token, body={
            'data': {
                'type': 'appInfoLocalizations',
                'id': loc_id,
                'attributes': {'name': name, 'subtitle': subtitle},
            }
        })
    else:
        code, body = req('POST', '/appInfoLocalizations', token, body={
            'data': {
                'type': 'appInfoLocalizations',
                'attributes': {'locale': locale, 'name': name, 'subtitle': subtitle},
                'relationships': {
                    'appInfo': {'data': {'type': 'appInfos', 'id': app_info_id}}
                }
            }
        })
    if code in (200, 201):
        print(f"[appInfo:{locale}] ok name='{name[:30]}' subtitle='{subtitle[:20]}'")
    else:
        print(f"[appInfo:{locale}] FAILED {code}: {json.dumps(body)[:300]}")


def get_editable_version(token):
    code, body = req('GET', f'/apps/{APP_ID}/appStoreVersions?filter[platform]=IOS', token)
    if code != 200:
        return None
    versions = body.get('data', [])
    # Prefer EDITABLE states.
    editable_states = {
        'PREPARE_FOR_SUBMISSION', 'METADATA_REJECTED', 'DEVELOPER_REJECTED',
        'WAITING_FOR_REVIEW', 'INVALID_BINARY',
    }
    for v in versions:
        if v['attributes']['appStoreState'] in editable_states:
            return v['id'], v['attributes']
    if versions:
        return versions[0]['id'], versions[0]['attributes']
    return None


def list_version_localizations(token, version_id):
    code, body = req('GET', f'/appStoreVersions/{version_id}/appStoreVersionLocalizations', token)
    if code != 200:
        return {}
    return {x['attributes']['locale']: x['id'] for x in body.get('data', [])}


def upsert_version_localization(token, version_id, existing, locale, attributes):
    if locale in existing:
        loc_id = existing[locale]
        code, body = req('PATCH', f'/appStoreVersionLocalizations/{loc_id}', token, body={
            'data': {
                'type': 'appStoreVersionLocalizations',
                'id': loc_id,
                'attributes': attributes,
            }
        })
    else:
        code, body = req('POST', '/appStoreVersionLocalizations', token, body={
            'data': {
                'type': 'appStoreVersionLocalizations',
                'attributes': dict(attributes, locale=locale),
                'relationships': {
                    'appStoreVersion': {'data': {'type': 'appStoreVersions', 'id': version_id}}
                }
            }
        })
    if code in (200, 201):
        print(f"[version:{locale}] ok ({list(attributes.keys())})")
    else:
        print(f"[version:{locale}] FAILED {code}: {json.dumps(body)[:300]}")


def main():
    token = make_token()

    app_info_id = get_app_info(token)
    print(f"[appInfo] id={app_info_id}")
    existing_info = list_app_info_localizations(token, app_info_id)

    for folder, locale in LOCALES.items():
        name = read_meta(folder, 'name.txt')
        subtitle = read_meta(folder, 'subtitle.txt')
        if name and subtitle:
            upsert_app_info_localization(token, app_info_id, existing_info, locale, name, subtitle)

    version = get_editable_version(token)
    if not version:
        print("[version] no editable version — only app-level metadata pushed")
        return
    version_id, attrs = version
    print(f"[version] id={version_id} state={attrs.get('appStoreState')}")
    existing_ver = list_version_localizations(token, version_id)

    for folder, locale in LOCALES.items():
        description = read_meta(folder, 'description.txt')
        keywords = read_meta(folder, 'keywords.txt')
        promotional = read_meta(folder, 'promotional_text.txt')
        marketing = read_meta(folder, 'marketing_url.txt')
        support = read_meta(folder, 'support_url.txt')
        whats_new = read_meta(folder, 'release_notes.txt')

        attrs = {}
        if description:
            attrs['description'] = description
        if keywords:
            attrs['keywords'] = keywords
        if promotional:
            attrs['promotionalText'] = promotional
        if marketing:
            attrs['marketingUrl'] = marketing
        if support:
            attrs['supportUrl'] = support
        # whatsNew is rejected for the very first app version (Apple constraint).
        is_first_version = attrs and attrs.get('appStoreState') in (None, 'PREPARE_FOR_SUBMISSION')
        if whats_new and not is_first_version:
            attrs['whatsNew'] = whats_new
        if attrs:
            upsert_version_localization(token, version_id, existing_ver, locale, attrs)


if __name__ == '__main__':
    main()
