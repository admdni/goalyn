#!/usr/bin/env python3
"""Register bundle id + create App Store Connect app for Goalyn.

Idempotent: skips when records already exist.
"""

import os
import sys
import time
import json
import jwt
import urllib.request
import urllib.error
from pathlib import Path


KEY_ID    = '249G24VRT6'
ISSUER_ID = '05481e43-1010-4891-b4ec-68befd43ade4'
BUNDLE_ID = 'com.tanaltay.goalyn'
APP_NAME  = '飞饼体育'
SKU       = 'GOALYN-2025-001'
PRIMARY_LOCALE = 'zh-Hant'

ROOT = Path(__file__).resolve().parent.parent
KEY_PATH = ROOT / f'AuthKey_{KEY_ID}.p8'

API = 'https://api.appstoreconnect.apple.com/v1'


def make_token():
    key = KEY_PATH.read_text()
    return jwt.encode(
        {
            'iss': ISSUER_ID,
            'iat': int(time.time()),
            'exp': int(time.time() + 1200),
            'aud': 'appstoreconnect-v1',
        },
        key,
        algorithm='ES256',
        headers={'kid': KEY_ID, 'typ': 'JWT'},
    )


def request(method, path, token, body=None):
    url = API + path
    data = None
    headers = {'Authorization': f'Bearer {token}'}
    if body is not None:
        data = json.dumps(body).encode()
        headers['Content-Type'] = 'application/json'
    req = urllib.request.Request(url, data=data, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req) as r:
            return r.status, json.loads(r.read().decode())
    except urllib.error.HTTPError as e:
        return e.code, json.loads(e.read().decode())


def ensure_bundle(token):
    code, body = request('GET', f'/bundleIds?filter[identifier]={BUNDLE_ID}', token)
    if code == 200 and body.get('data'):
        bundle_id_resource = body['data'][0]['id']
        print(f"[bundle] exists: {bundle_id_resource}")
        return bundle_id_resource
    code, body = request('POST', '/bundleIds', token, body={
        'data': {
            'type': 'bundleIds',
            'attributes': {
                'identifier': BUNDLE_ID,
                'name': 'Goalyn iOS',
                'platform': 'IOS',
            }
        }
    })
    if code in (200, 201):
        rid = body['data']['id']
        print(f"[bundle] created: {rid}")
        return rid
    print(f"[bundle] failed: {code} {body}")
    sys.exit(1)


def find_app(token):
    code, body = request('GET', f'/apps?filter[bundleId]={BUNDLE_ID}', token)
    if code == 200 and body.get('data'):
        return body['data'][0]['id']
    return None


def create_app(token, bundle_resource):
    code, body = request('POST', '/apps', token, body={
        'data': {
            'type': 'apps',
            'attributes': {
                'bundleId': BUNDLE_ID,
                'name': APP_NAME,
                'primaryLocale': PRIMARY_LOCALE,
                'sku': SKU,
            },
            'relationships': {
                'bundleId': {
                    'data': {'type': 'bundleIds', 'id': bundle_resource}
                }
            }
        }
    })
    if code in (200, 201):
        print(f"[app] created: {body['data']['id']}")
        return body['data']['id']
    print(f"[app] failed: {code} {json.dumps(body)[:600]}")
    return None


def main():
    if not KEY_PATH.exists():
        print(f"Key not found: {KEY_PATH}")
        sys.exit(1)
    token = make_token()
    bundle = ensure_bundle(token)
    app_id = find_app(token)
    if app_id:
        print(f"[app] exists: {app_id}")
    else:
        create_app(token, bundle)


if __name__ == '__main__':
    main()
