What is Mail Plugin Manager?
============================

Mail Plugin Manager makes installing, updating, and fiddling with Mail.app plugins easy. 

Getting Started: Users
======================

You can download the most recent version of Mail Plugin Manager from the Downloads tab.

Copy the application somewhere useful (such as your Applications folder), and launch it.
From there, you can enable, disable, remove, or update your installed Mail.app plugins.

Getting Started: Developers
===========================

We want Mail Plugin Manager to be useful to all Mail.app plugin developers. It's BSD licensed, so you can include it with your plugin, regardless of its license.

Out of the box, Mail Plugin Manager will do basic installation, removal, enabling, and disabling of your plugin. With a few small tweaks, your plugin can play even more nicely with it.

Mail Plugin Manager looks for some standard (and a few nonstandard) keys in your plugin's Info.plist.

Standard keys that you probably already supply:

  CFBundleName: Your plugin's name.
  CFBundleVersion: The current version. It uses this both to display the installed version, and to check for updates.
  
Custom keys you can add so users can see more information about your plugin:

  BundleDescription: A few sentences describing your plugin. Displayed in the information window when users double-click on your plugin.
  BundleWebsiteURL: Shown as a link below the plugin description.
  
Sparkle keys you can add so that Mail Plugin Manager can check for updates to your plugin:

  SUFeedURL
  
Contributing
============

We welcome your contributions! Whether you're a developer, a designer, or a user, the Mail Plugin Manager project can benefit from your participation.

(How to contribute TK)


