#!/bin/sh
set -e

# setup key
mkdir -p /root/.ssh/
echo "${INPUT_DEPLOYKEY}" >/root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
ssh-keyscan -t rsa github.com >>/root/.ssh/known_hosts

git config --global user.name "${INPUT_USERNAME}"
git config --global user.email "${INPUT_EMAIL}"

# setup hexo env
npm install hexo-cli -g
npm install

# generate&publish
npx hexo g
npx hexo d

# update files
INPUT_BRANCH=${INPUT_BRANCH:-master}

if ${INPUT_IF_UPDATE_FILES}; then
    [ -z "${INPUT_GITHUB_TOKEN}" ] && {
        echo 'Missing input "github_token: ${{ secrets.GITHUB_TOKEN }}".'
        exit 1
    }
    remote_repo="https://${GITHUB_ACTOR}:${INPUT_GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
    if [ -z "$(git status --porcelain)" ]; then
        echo "nothing to update."
    else
        git commit -m "triggle by commit ${GITHUB_SHA}" -a
        git push "${remote_repo}" HEAD:${INPUT_BRANCH}
    fi
fi

# Purge cache in CloudFlare
if ${INPUT_IF_UPDATE_CLOUDFLARE}; then
    [ -z "${INPUT_CLOUDFLARE_TOKEN}" ] && {
        echo 'Missing input cloudflare api key'
        exit 1
    }
    if [ -n "${INPUT_PURGE_LIST}" ]; then
        HTTP_RESPONSE=$(curl -sS "https://api.cloudflare.com/client/v4/zones/${INPUT_CLOUDFLARE_ZONE}/purge_cache" \
            -H "Authorization: Bearer ${INPUT_CLOUDFLARE_TOKEN}" \
            -H "Content-Type: application/json" \
            -w "HTTPSTATUS:%{http_code}" \
            --data '{"files":'"${INPUT_PURGE_LIST}"'}')
    else
        HTTP_RESPONSE=$(curl -sS "https://api.cloudflare.com/client/v4/zones/${INPUT_CLOUDFLARE_ZONE}/purge_cache" \
            -H "Authorization: Bearer ${INPUT_CLOUDFLARE_TOKEN}" \
            -H "Content-Type: application/json" \
            -w "HTTPSTATUS:%{http_code}" \
            --data '{"purge_everything":true}')
    fi

    # curl-get-status-code-and-response-body
    # https://gist.github.com/maxcnunes/9f77afdc32df354883df

    HTTP_BODY=$(echo "${HTTP_RESPONSE}" | sed -E 's/HTTPSTATUS\:[0-9]{3}$//')
    HTTP_STATUS=$(echo "${HTTP_RESPONSE}" | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')

    # example using the status
    if [ "${HTTP_STATUS}" -eq "200" ]; then
        echo "Clear successful!"
        exit 0
    else
        echo "Something was wrong, error info:"
        echo "${HTTP_BODY}"
        exit 1
    fi
fi
