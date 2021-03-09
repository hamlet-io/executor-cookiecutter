## Hamlet Deploy - Executor Patterns

> previously known as executor-cookiecutter

This repository is a part of the Hamlet Deploy application. It provides cookiecutter templates to Hamlet Deploy for quick creation of files and directory structures.

See https://docs.hamlet.io for more info on Hamlet Deploy

### Installation

```bash
git clone https://github.com/hamlet-io/executor-cookiecutter.git
```

### Configuration

Hamlet Deploy Executor - Patterns requires the following Environment Variable(s) to be used.

| Variable            | Value                                                                                    |
|---------------------|------------------------------------------------------------------------------------------|
| GENERATION_PATTERNS_DIR | A fully qualified filepath to a local copy of the Hamlet Deploy Patterns repository. |


### Update 

To manually perform an update on Patterns, simply pull down the latest changes using git.

```bash
cd ./path/to/patterns
git pull
```

### Usage

The Executor Patterns capabilities of the Hamlet Deploy application is available within the CLI. 

Run `hamlet generate --help` using the CLI for available options.