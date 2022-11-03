# markup-diff

This script uses **`wget`** to scrape a site and keep a copy of it locally (as .html files) these snapshots can then be diff'ed to determine if there have been any regressions.

---
## This does not handle visual or behavioral regressions. It knows nothing about runtime behavior, it just saves the raw HTML from the server.

-----

### How to Install

1. Make sure you have **`wget`**, and **`coreutils`** installed. On macOS can be installed via [homebrew](https://brew.sh/).
    ```bassh
    brew update
    brew install wget
    brew install coreutils
    ```
    > **[ NOTE ]:**
    >
    > If your're running *nix or WSL, you don't need to install `coreutils` but if you get an error about "command not found: `realpath`" you'll need to find the appropriate package for your distro, or edit the script to use `readlink` or something instead, you'll figure it out.

2. Download this script and save it somewhere. It's probably not worth registering as a package so you can download/install it however, wherever, you want. 
    
    I suggest you make it accessible via your `$PATH` by creating a symbolic link to `/usr/bin/local`.
    
    Here is simple way to do it that _shouldn't_ cause ~~any~~ too many issues.
    
    ```bash
    git clone github.com/patrick-lienau/markup-diff.git
    cd markup-diff 
    chmod +x ./markup-diff.sh
    ln -s "$(pwd)/markup-diff.sh" /usr/local/bin/markup-diff
    ```



### How to use

1. Create a folder somewhere, we will create an empty git repo and thus this should be outside of the project's directory tree.
    ```bash
    cd ~/dev
    mkdir site-regressions
    cd site-regressions
    git init
    ```
2. Create the first snapshot of the site's __*local*__ instance of the site in it's __*"before"*__ state.
    > **THIS WILL NOT WORK AGAINST QA** 
    >
    > QA uses http auth and this functionality is not yet supported.
    ```sh
    diff-markup http://some-site.lndo.site/
    ```
2. Wait. This can take 5-30min depending on the size of the site.
3. Commit changes so they can be reviewed later. `diff-markup` has already staged them for you, but you'll need to provide a commit message.
    ```sh
    git commit -m "before snapshot"
    ```
4. Transition the _**local**_ instance of the site in question to its __*"after"*__ state. 
5. Make sure you're still in the same folder as before where we stored the first snapshot (the next step is destructive so you want to make sure to be in the right directory)
    ```sh
    cd ~/dev/site-regressions
    ```
6. Capture the site in it's __*"after"*__ state:
    
    
    > **[ NOTE ]:** 
    > * `markup-diff` deletes everything its working directory to ensure `wget` does not attempt a "partial" scrape. Make sure you are in the correct directory.
    > * `markup-diff` won't let you proceed when the git tree is dirty (ie: there are untracked files or changes which have not been committed). If you get a message about this, return to step 3
    
    Run the following again the same url as before
    ```sh
    diff-markup http://some-site.lndo.site/
    ```
7. Wait. This can take 5-30min depending on the size of the site.
8. Commit changes so they can be reviewed later. `diff-markup` has already staged them for you, but you'll need to provide a commit message.
    ```sh
    git commit -m "after snapshot"
    ```
9. Review the changes. 
    ```sh
    git diff HEAD~1 # diff the last two changes
    ```

    or use your favorite diff viewer/git GUI.
