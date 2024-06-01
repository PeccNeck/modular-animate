# Modular Animations Toolkit
A drop-in replacement for Roblox's default Animate script, written from the ground up and meant to replicate default behaviors as closely as possible. Designed primarily for use in [Rojo](https://github.com/rojo-rbx/rojo) projects.

## Integration
Due to incompatibilities with how this repository is set up and how Rojo handles projects, there are three different ways to import this into your project, each with their own pros and cons. These are listed below, in order of least complexity to most.

---
### Manual from Release
The simplest way of adding this to your project is to go to Releases, download the latest release as a `.rbxm`, and upload it directly to your game.

__Pros__
- Quickest, easiest method
- Best for beginners

__Cons__
- You won't be able to receive any automatic updates, requiring you to check and merge manually
- If added to a Rojo project, limits your customizeability significantly
- An incorrectly-configured project could wipe all your changes (see: [Rojo Project Format](https://rojo.space/docs/v7/project-format/#instance-description))

---
### Fork and Manual Sync
Despite being the second option listed here, I *strongly* recommend against doing this, even for a solo project.

It's possible to set up your own fork of this repository and manually sync it yourself when making changes, including pulling new changes from upstream.

__Pros__
- Allows you to pull in new changes/updates from upstream
- Simple to set up
- Best for making independent contributions directly to the project

__Cons__
- Introduces horrible workflow practices
- An incorrectly-configured project could require you to re-sync constantly
- Not viable for workspaces with multiple collaborators
- Please don't do this in an actual project

---
### Add as Git submodule
While the most complex method listed here, this is the one I'd personally recommend for most projects; though this one requires a few additional steps to set up correctly.

__Pros__
- Scales best with teams and larger projects
- Allows you to pull new updates the quickest
- Can be paired with a fork for additional modifications or to contribute upstream

__Cons__
- More difficult to set up
- Requires additional git knowledge to maintain
- If not paired with a fork, cannot be directly modified, and will require additional scripts to "patch"

You can read all about Git submodules [here](https://git-scm.com/book/en/v2/Git-Tools-Submodules), but the general steps are as follows:

0. Open git bash. This can usually be done from your code editor, such as Visual Studio Code.
1. Run `git submodule add https://github.com/PeccNeck/modular-animate` and append your desired directory to the end.
    - If you're using a fork, replace the link with a link to your own fork.
    - If you're given an error about it "already existing in index", you already have a folder there. Rename, or backup and delete, the folder; run `git rm -r` and append your directory, then try again.
    - Your commands should look like `git submodule add https://github.com/PeccNeck/modular-animate src/StarterCharacter/Animate`, for instance.
2. Inform your collaborators about the change in workflow, as they'll need to follow the next steps for themselves:
3. When a collaborator pulls changes, they'll need to run the git bash command `git submodule update --init --recursive`. This will provide the actual files for the submodule.
4. Whenever you, or a collaborator, would like to update your local copy of the submodule, run `git submodule update --remote --recursive`.