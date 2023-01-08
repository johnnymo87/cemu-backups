# Cemu Scripts

Scripts for doing things like backing up and restoring Cemu game data to and from my S3 bucket. Lots of things are hardcoded in these scripts, as it's simpler that way for now.

Credit for these scripts goes to [this blogpost](https://skarlso.github.io/2016/04/16/minecraft-server-aws-s3-backup/), which offers a script to backup minecraft server world data to an s3 bucket.

## Depedencies

* `bash`.
* `trap` for cleaning up at the end of succesful or failed runs of a script.
* `pushd` and `popd` for navigating to and from the game data directory.
* `zip` and `unzip` for archiving and unarchiving game data.
* [`aws`](https://aws.amazon.com/cli/) for interacting with an s3 bucket.
* [`direnv`](https://direnv.net/) for automatically sourcing environment variables stored in an `.envrc` file.

## Installation

1. Create an S3 bucket. Mine is called `jonathan-mohrbacher-cemu-01`.
1. Initialize the environment variable file.
   ```bash
   cp .envrc.sample .envrc
   ```
1. Setup AWS credentials. Follow [this guide](https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-walkthroughs-managing-access-example1.html) to create a user dedicated to using AWS CLI to interact with this bucket.
   * Set the user's credentials in the `.envrc` file.
     ```bash
     export AWS_ACCESS_KEY_ID=...
     export AWS_SECRET_ACCESS_KEY=...
     ```

## Usage

1. Source the `commands.bashrc` file.
   ```bash
   source commands.bashrc
   ```
1. Invoke commands, for example ...
   ```bash
   restoreLiviaZelda game-data-2023-01-08-14-45-30.zip
   ```
