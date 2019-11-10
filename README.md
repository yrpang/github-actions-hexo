# Github Action for Hexo

The GitHub Actions for automatic generate and deploy hexo-based blog.

**Features:**

- Update source files after hexo g

- Clean CloudFlare cached after deploy(Only support CloudFlare Token. For more you can try [Cloudflare Purge Cache](https://github.com/marketplace/actions/cloudflare-purge-cache))

## Usage

Before using this action, please config hexo env locally and install `hexo-deployer-git` plugin.
The official reference documentation of the plugin is [https://hexo.io/docs/deployment.html](https://hexo.io/docs/deployment.html)

e.g.

```yml
# Deployment
## Docs: https://hexo.io/docs/deployment.html
deploy:
  type: git
  repo: git@github.com:yrpang/yrpang.github.io.git
  branch: master
```

### Prepare

- Apply a DEPLOY_KEY for the repository of your GitHub Page

- (*Use Cloudflare Only*)Apply a CLOUDFLARE_API_KEY

### Example Workflow file

```yml
name: Hexo Build and Deploy

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - name: Cache node modules
        uses: actions/cache@v1
        with:
          path: node_modules
          key: ${{runner.OS}}-${{hashFiles('**/package-lock.json')}}
      - uses: yrpang/github-actions-hexo@master
        with:
          deploykey: ${{secrets.DEPLOY_KEY}}
          username: YOUR_USER_NAME
          email: YOUR_EMAIL_ADDRESS
```

### Inputs

| Name                 | Type    | Required | Default  | Description                                                             |
|----------------------|---------|----------|----------|-------------------------------------------------------------------------|
| deploykey            | secrets | **Yes**  |          | The deploy key of your GitHub Page repository                           |
| username             | string  | **Yes**  |          | Your user name                                                          |
| email                | string  | **Yes**  |          | Your email address                                                      |
| if_update_files      | boolean |          | false    | Whether update the source file after generate                           |
| github_token         | secrets |          |          | Token for the repo. Can be passed in using $\{{ secrets.GITHUB_TOKEN }} |
| branch               | string  |          | 'master' | The branch of the blog source code                                      |
| if_update_cloudflare | boolean |          | false    | Whether update cloudflare                                               |
| cloudflare_zone      | string  |          |          | the cloudflare zone                                                     |
| cloudflare_token     | secrets |          |          | Your cloudflare token                                                   |

### License

The Dockerfile and associated scripts and documentation in this project are released under the [MIT License](https://github.com/yrpang/github-actions-hexo/blob/master/LICENSE).

### No affiliation with GitHub Inc.

GitHub are registered trademarks of GitHub, Inc. GitHub name used in this project are for identification purposes only. The project is not associated in any way with GitHub Inc. and is not an official solution of GitHub Inc. It was made available in order to facilitate the use of the site GitHub.
