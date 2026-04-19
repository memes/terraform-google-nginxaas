# Changelog

## [0.1.0](https://github.com/memes/terraform-google-nginxaas/compare/v0.0.1...v0.1.0) (2026-04-19)


### Features

* Add support for Secret Manager secrets ([3b1de8b](https://github.com/memes/terraform-google-nginxaas/commit/3b1de8b25f75a1d3e51071a95e3b9eb64d41582d))
* Expose service_accounts as variable ([8b6150a](https://github.com/memes/terraform-google-nginxaas/commit/8b6150abdd92bce0e90a54ff6c9a64b5893b2c13))
* Ports must be explicit; no port, no NEGs ([2878eb6](https://github.com/memes/terraform-google-nginxaas/commit/2878eb64a1132173e19b32b33aba3123c6c2923b))
* Support multiple TCP ports per-attachment ([33eaeec](https://github.com/memes/terraform-google-nginxaas/commit/33eaeecfb5e03ff38a1ff9b2d5f294be43bc9eeb))


### Bug Fixes

* Add IAM for secret only when pool active ([66abdd8](https://github.com/memes/terraform-google-nginxaas/commit/66abdd8b927e4ca897b0d916803b6352417edc41))
* Allow service_attachment to be just a project ([9426acc](https://github.com/memes/terraform-google-nginxaas/commit/9426accc0e427d6a5192dccc154301d1c41e0dd3))
* Handle outputs with multiple per region ([942a86f](https://github.com/memes/terraform-google-nginxaas/commit/942a86f0729bdd707fd0940c5f887a74b1f1cc6c))
* Missing quote in attribute value ([b3eb1fd](https://github.com/memes/terraform-google-nginxaas/commit/b3eb1fdbbf8eb9e3b51f35b17acf724c59729b61))
* Output NEGs by name and region ([1275534](https://github.com/memes/terraform-google-nginxaas/commit/1275534cc8030822a48062c31dc8eec9bd283c41))
* Revert back to nginxaas attributes ([f6d194f](https://github.com/memes/terraform-google-nginxaas/commit/f6d194fc8fc3f5efd673cd6809034b99ae55c9ed))
* Revert prior commit ([db3cc41](https://github.com/memes/terraform-google-nginxaas/commit/db3cc41206c8413857b5e54f10f902b6047a64d8))
* Rework IAM logic; deployments are failing ([6e01da9](https://github.com/memes/terraform-google-nginxaas/commit/6e01da9d8bc6b3d8ad1364ccd3b306af3c0cede1))
* Typo in membership; use principal not set ([77a1d62](https://github.com/memes/terraform-google-nginxaas/commit/77a1d625fd36fb275daa0693069c4e3240908800))
