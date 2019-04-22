# streamsx.crossdc-failover documentation README


This toolkit documentation project is currently incubating.

It is built on and inspired by the [minimal-mistakes](https://github.com/mmistakes/minimal-mistakes) great Jekyll theme and shall provide a unique layout for all Streams toolkit documentation.
Main idea here is that each IBM Streams toolkit uses this theme on its gh-pages branch and adds the necessary documentation as markdown documents. 
In the end, each toolkit will have this single web site for collecting all the information. Actually there are many places where one can find IBM Streams toolkit specific information. But, even if there is information available about the toolkit usage, there is nearly no information regarding the development and testing of a toolkit.
This theme shall enable and encourage everyone who is involved in developing and testing IBM Streams toolkits to document as much as possible.

New pages can be created within the github web by writing markdown files. Navigation topics are simply added with two lines in the navigation.yml file.

Look here to see it in action [toolkit-theme-2](https://rnostream.github.io/toolkit-theme-2/). This sample documentation site runs from this master branch as a github page.
Pull this master to your gh-pages branch and add/delete/modify the files in your /_docs directory and navigation details in /_data/navigation.yml.

## How to add content

All content is written in Markdown Language and is located in the `_docs` directory. Insert the following header into every MD file that you create:

```yml
---
title: "Toolkit Development overview"
permalink: /docs/developer/overview/               # make sure this is the same as 'url' in _data/navigation.yml
excerpt: "Contributing to this toolkits development."
last_modified_at: 2018-09-15T12:37:48-04:00
redirect_from:
   - /theme-setup/
sidebar:
   nav: "developerdocs"                            #chose one of 'knowledgedocs', 'userdocs' or 'developerdocs' from navigation.yml
---
{% include toc %}
{% include editme %}
```

Make sure that the `permalink` is unique within the MD documents and terminates with a `/` character. 
Add the page with the permalink to the `_data/navigation.yml` file to specify where the content shall be visible in the menu.
The actual filename of the MD files in the `_docs`directory is only important for the `prev` and `next` navigation. 
The alphabetic names of the MD files determine the sequence of the previous-next navigation.

