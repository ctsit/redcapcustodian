# Randomization Management

REDCap Custodian contains a suite of functions to help a developer work with randomization data in ways that are not supported withing the REDCap code. 

## Moving a Production project with allocated randomization records

These tools were created to allow a production project with randomization turned on to be moved to another REDCap project. REDCap doesn't allow that, so the work has to be done in the backend with database reads and write. As the tables involved have REDCap project IDs, randomization IDs, eventIDs, and allocations IDs embedded, the work requires multiple transformations before writing the randomization configuration to the target project. 

An example ETL is saved at [`../etl/copy_allocated_randomization.R`](../etl/copy_allocated_randomization.R) That script and the functions in it calls were designed to fit into this workflow:

### Preparation
1. Start with a production project with randomization turned on and configured, data entered and records randomized. This is the _source project_. Note its project ID.
1. Copy/clone the source project. Either use the _Copy the Project_ button in REDCap Project Setup, or do an XML export and an import. This new project is the _target project_. Note its project ID.
1. Turn off randomization in the target project if the copy/cloning process turned it on. This probably seems strange, but it's needed to allow data import into the randomization field and to trick REDCap into moving the project to production with data in the "randomization" field and the assignments in the allocation table.
1. Do any reconfiguration work needed on the target project. You should be able to move the fields to other forms and to other events if needed.  That said, do not change the names of the stratification and randomization fields. 
1. Copy the script `./etl/copy_allocated_randomization.R` and setting your own values for source and target project ids.
1. Run your `copy_allocated_randomization.R` script. It should mirror the randomization configuration from the source project to the target project. If you cloned the project with the _Copy the Project_ button, the script will complain that some configuration data exists. That is fine. Regardless how you cloned the project, the script should complain that you have not met the requirements for turn on randomization. You are _supposed_ to see that warning at this point.

### Activation
1. Take the source project offline.
1. If any changes have occurred to the data in the source project since you cloned it, re-export that data from the source project and import it into the target project.
1. Immediately move the target project to production.
1. Immediately re-run your `copy_allocated_randomization.R` script. It should turn on randomization in the target project.
1. Revoke access to the source project.
1. You are done.

## Limitations

These randomization management tools do not support DAG group_ids as randomization variables. They could, but they don't as they were not needed for the project that inspired these tools. Do not try to use these on a project that uses DAGs in the randomization configuration.

The tools do not support changing the randomization configuration. They might form a good foundation for that, but they do not support it.
