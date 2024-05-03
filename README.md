# Compilation instructions

- Cloning GOTM: Follow the [guidelines](https://gotm.net/portfolio/software/)
- Building GOTM with FABM: see [here](https://gotm.net/software/linux/). Note: you can also check the `build.sh` file

# Modify FABM's code

In GOTM, find the folder `src` in `/code/extern/fabm/src` and modify the file `CMakeLists.txt` by adding `rbins` in the list of institutes.

```set(DEFAULT_INSTITUTES
    akvaplan     # Akvaplan-niva, Norway
    au           # University of Aarhus, Denmark
    bb           # Bolding & Bruggeman - formerly Bolding & Burchard
    csiro        # Commonwealth Scientific and Industrial Research Organisation, Australia
    ersem        # European Regional Seas Ecosystem Model, https://doi.org/10.5194/gmd-9-1293-2016
    examples     # Examples supplied with FABM itself
    gotm         # Models ported from original GOTM/BIO library
    ihamocc      # isopycnic coordinate HAMburg Ocean Carbon Cycle model, https://doi.org/10.5194/gmd3-2393-2020
    iow          # Leibniz Institute for Baltic Sea Research, Germany
    jrc          # EC - Joint Research Centre, Ispra, Italy
    mops         # Model of Oceanic Pelagic Stoichiometry, https://doi.org/10.5194/gmd-8-2929-2015
    msi          # Marine Systems Institute, Tallinn University of Technology, Estonia
    nersc        # Nansen Environmental and Remote Sensing Center
    niva         # Norwegian Institute for Water Research, Norway
    pclake       # The PCLake model - reference implementation
    pisces       # Pelagic Interactions Scheme for Carbon and Ecosystem Studies, https://doi.org/10.54/gmd-8-2465-2015
    pml          # Plymouth Marine Laboratory, United Kingdom
    rbins        # Royal Belgium Institute of Natural Sciences, Belgium
    selma        # Simple EcoLogical Model for the Aquatic - PROGNOS
    su           # Swansea University, United Kingdom
    uhh          # University of Hamburg, Germany
)
```

Then, go in the `models` directory (`cd models`) and create a folder named `rbins`. Inside that folder, `git pull` the `gotm-fabm` repo.

# Run a simulation of a simple model

From your `gotm` executable (it should be inside your `build` directory, see the build instructions), you can execute `./gotm gotm.yaml`. This will run a simulation and output a `voet.nc` file that you can inspect with ncview. Note that you can modify the output's filename and other specifications inside that yaml file. Similarly, you can modify initial concentrations and parameters inside the `fabm.yaml` file.

