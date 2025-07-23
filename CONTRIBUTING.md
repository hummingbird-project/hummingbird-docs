# Contributing

## Legal
By submitting a pull request, you represent that you have the right to license your contribution to the community, and agree by submitting the patch
that your contributions are licensed under the Apache 2.0 license (see [LICENSE](LICENSE)).

## Contributor Conduct
All contributors are expected to adhere to the project's [Code of Conduct](CODE_OF_CONDUCT.md).

## Build Process

Hummingbird documentation is generated using Apple's docc documentation compiler. The build process is triggered from the script `scripts/build-docc.sh`. We don't use the docc plugin as currently there is no way to include links between modules while using the plugin. Documentation is built in a `docs` folder at the root of this project. It is best to run this script with the `HUMMINGBIRD_VERSION` environment variable set. This will ensure your documentation is placed in the correct folder for the current version of Hummingbird.

```
HUMMINGBIRD_VERSION=2.0 ./scripts/build-docc.sh
```
If you are editing documentation inside VS Code, the default build task runs the code above.

## Testing changes

To test changes locally you can use [swift-web](https://github.com/adam-fowler/swift-web). Once it is installed run `swift web docs` to run a local HTTP file server with base directory set to the `docs` folder. You can then access the documentation in your web browser from `http://localhost:8001/<version-number>/documentation/index`.

## Submitting changes

Changes should be submitted in a PR. In the PR please describe what the changes are and why they are needed. Also try to keep PRs to a minimal number of changes as possible. It is a lot easier to review multiple PRs of smaller changes than one big PR.

## Deploying changes

Currently v1 documentation is stored on the `1.x.x` branch and v2 documentation is stored on the `main` branch. As soon as a PR is merged into either of these branches the deploy process will begin and you should see your changes live in less than 10 minutes.
