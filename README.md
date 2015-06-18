# Adobe Experience Manager 6.1 Extension: Create Design Custom Search Predicate

This is a sample package showing how to create a custom search predicate for Sites administration console and use it with custom Search Facets.

The package is designed to work for AEM 6.1 GA.


## Build & Install
 
This project uses Maven for building. Common commands:

From the project directory, run ``mvn clean install content-package:install`` to build the bundle and content package and install to a CQ instance.

## Using with VLT

To use vlt with this project, first build and install the package to your local CQ instance as described above. Then cd to `src/main/content/jcr_root` and run

    vlt --credentials admin:admin co http://localhost:4502/crx/-/jcr:root . --force

Once the working copy is created, you can use the normal ``vlt up`` and ``vlt ci`` commands.