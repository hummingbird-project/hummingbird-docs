# Getting Started with Hummingbird

Create a new project on GitHub or an app locally from a starter template.

## Overview

The Hummingbird project provides multiple entry points for getting started.
Create your own project that uses Hummingbird from a [starting template](https://github.com/hummingbird-project/template) to jump right in.
For a walk-through building an application with Hummingbird, explore and follow along the [Build a Todos Application](https://docs.hummingbird.codes/2.0/tutorials/todos) tutorial.
Take some time to explore the [hummingbird examples](https://github.com/hummingbird-project/hummingbird-examples/), individual project snapshots that use common application patterns.

### Creating a new local project from the starting template

Clone the starting template to your local machine:

    git clone https://github.com/hummingbird-project/template

Create a new directory for your project:

    mkdir MyNewProject
    cd MyNewProject

Run the configure script provided to create a new folder and project inside:

    ../template/configure.sh MyNewProject

To run your app:

    swift run App

The starting template is also designed so that you can create a new GitHub repository from it.

### Creating a new GitHub repository from the template

- Sign in to GitHub.
- Navigate to https://github.com/hummingbird-project/template.
- Click "Use this template" and create your new repository.
- Clone the repository to a codespace or your local machine.
- Run the configuration script (`./configure.sh`) to configure your new project.
