#!/usr/bin/env python3
"""Create a 1.0.0 App Store Version on the Goalyn app, idempotent."""

import json
import sys
import time
import urllib.request
import urllib.error
from pathlib import Path
import jwt


KEY_ID = '249G24VRT6'
ISSUER_ID = '05481e43-1010-4891-b4ec-68befd43ade4'
APP_ID = '6767691750'
VERSION_STRING = '1.0.0'

ROOT = Path(__file__).resolve().parent.parent
KEY_PATH = ROOT / f'AuthKey_{KEY_ID}.p8'
API = 'https://api.appstoreconnect.apple.com/v1'


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
            return resp.status, json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        return e.code, json.loads(e.read().decode())


def existing_version(token):
    code, body = req('GET', f'/apps/{APP_ID}/appStoreVersions?filter[versionString]={VERSION_STRING}&filter[platform]=IOS', token)
    if code == 200 and body.get('data'):
        return body['data'][0]
    return None


def main():
    token = make_token()
    existing = existing_version(token)
    if existing:
        print(f"[version] exists: id={existing['id']} state={existing['attributes'].get('appStoreState')}")
        return
    code, body = req('POST', '/appStoreVersions', token, body={
        'data': {
            'type': 'appStoreVersions',
            'attributes': {
                'platform': 'IOS',
                'versionString': VERSION_STRING,
                'releaseType': 'MANUAL',
            },
            'relationships': {
                'app': {'data': {'type': 'apps', 'id': APP_ID}}
            }
        }
    })
    if code in (200, 201):
        print(f"[version] created id={body['data']['id']}")
    else:
        print(f"[version] failed {code}: {json.dumps(body)[:600]}")
        sys.exit(1)


if __name__ == '__main__':
    main()
