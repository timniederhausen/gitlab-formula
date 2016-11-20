gitlab
======

Formula to install and configure GitLab.

For a list of all available options, take a look at:

* `gitlab/defaults.yml`
* `gitlab/osmap.yml`
* `pillar.example`

Available states
================

.. contents::
    :local:

``gitlab``
----------

Install and configure GitLab.

``gitlab.pkg``
--------------

Install the GitLab package.

``gitlab.install``
--------------

Run the GitLab installation steps.

``gitlab.config``
-----------------

Write GitLab configuration files (gitlab.yml, database.yml).

``gitlab.service``
------------------

Configure (and start) the GitLab service.
