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

__Cons__
- Introduces horrible workflow practices
- An incorrectly-configured project could require you to re-sync constantly
- Not viable for workspaces with multiple collaborators
- Please don't do this it's not worth it

---
### Add as Git submodule
While the most complex method listed here, this is the one I'd personally recommend for most projects; though this one requires additional steps to set up correctly.

__Pros__
- Scales best with teams and larger projects
- Keeps everything self-contained in one repository
- Easily maintainable, quickest to update

__Cons__
- Most difficult to set up
- Structure incompatibilities require additional scripts, making it no longer a drop-in replacement

Allan please add details
