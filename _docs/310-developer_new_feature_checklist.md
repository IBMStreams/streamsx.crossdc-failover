---
title: "New Feature Checklist"
permalink: /docs/developer/new_feature_checklist/
excerpt: "New feature checklist"
last_modified_at: 2019-04-22T14:20:48+01:00
redirect_from:
   - /theme-setup/
sidebar:
   nav: "developerdocs"
---
{% include toc %}
{% include editme %}

### New Feature Checklist 

The following is a set of guidelines for adding a new feature to this toolkit.

* Add the feature to the code
  * Ensure that the toolkit documentation is updated appropriately
* Create or update an existing example project demonstrating how to use the new feature
  * Should be done in the `samples` folder
* Add a test case to ensure that the new feature gets tested 
  * Test the new feature in both the standalone in distributed execution modes.
* Generate the SPLDoc either by using the "Generate SPLDOC" option in Streams Studio or by using the spl-make-doc command line tool.
  * After pushing docs to `gh-pages`, verify that they are visible and correct when navigating to
  the [toolkit documentation web site](https://ibmstreams.github.io/streamsx.crossdc-failover/).
