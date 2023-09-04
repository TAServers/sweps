# 🔫 Scripted Weapons

A monorepo (or well, mono-addon) of custom scripted weapons for the Garry's Mod server.
Contains weapons made by the community that are too small on their own to be worth turning into an addon.

## 🦸‍♂️ Zero to Hero

1. Download and install the following programs if you haven't already:
	- Git
	- Visual Studio Code
		- Alternative editors will work, but might not support our tooling out the box
	- Garry's Mod dedicated server
	- You can use single-player for development, but many of the input-related hooks don't behave the same as on a real server
2. Clone this repository to your local server's `garrysmod/addons` directory with `git clone https://github.com/TAServers/gmod-utils.git`
	- Or if using SSH, `git clone git@github.com:TAServers/gmod-utils.git`
3. Install the recommended VSCode extensions
	- VSCode should prompt you when you open the project
	- If it doesn't, see `.vscode/extensions.json`
	- Some may require further setup to get working (e.g., installing external programs)
		- See the setup guides for each extension if they're not working automatically
4. Run the server and start working on your SWeps!

## ⌨️ Development process

1. Checkout a new branch from `master` with a descriptive name
	- If this is a new SWep, calling your branch the same as the SWep probably makes sense
	- If this is a fix or feature for an existing SWep, then use a short description of the changes you're making - for example, `fix-junkcannon-reload-time`
2. Commit changes to your new feature branch
3. When you're ready for your code to get deployed to the server, open a pull request to merge your feature branch into `master`
4. Wait for someone to review your code
	- If they have markups, you should respond on GitHub or resolve them by pushing fixes to your feature branch
5. Once your code is approved, you should get another dev to QA test it
	- Make sure you write concise and exhaustive testing instructions to make QA testing your changes easier (and get them merged faster)
	- If you're doing a QA, make sure to write your results in a thorough comment on the PR
6. After the QA passes (re-QA'ing as needed until all issues are resolved), you're ready to merge your changes
	- ⚠️ We're trusting that you wait for proper processes to pass before merging your changes. **PRs merged that haven't been through this process will be reverted**
7. Now that your branch is merged, you can safely delete it locally!
	- Your code will also be deployed to the server immediately, and will be mounted the next time the server is restarted
	- This is why it's extra important that we properly review and test changes before merging
