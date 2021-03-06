
// params.command
// params.synid
// params.synapseconfig
// params.inputfile
// params.parentid

def helpMessage() {
    log.info """
    Usage:
    nextflow run Sage-Bionetworks/synapse-nextflow --help
    Mandatory arguments:
      -profile                      Configuration profile to use. Can use multiple (comma separated)
                                    Available: conda, docker.
      --command                     synapseclient cli commands: {get, store}
      --synapseconfig               Synapse config file

      {get}
      nextflow run Sage-Bionetworks/synapse-nextflow --commands get --synapseconfig ~/.synapseConfig --synid syn1234
      --synid                       Synapse Id

      {store}
      nextflow run Sage-Bionetworks/synapse-nextflow --commands store --synapseconfig ~/.synapseConfig --inputfile README.md --parentid syn1234
      --inputfile                   Synapse Id
      --parentid                    Synapse parent id

    """.stripIndent()
}

// Show help message
if (params.help) {
    helpMessage()
    exit 0
}

if (params.command == "get")
    process synapse_get {

        input:
        val synid from params.synid
        file synapseconfig from file(params.synapseconfig)

        output:
        file '*' into result

        script:
        """
        echo "synapse -c $synapseconfig get $synid"
        synapse -c $synapseconfig get $synid
        """

    }
else if (params.command == "store")
    process synapse_store {

        input:
        file filepath from file(params.inputfile)
        val parent from params.parentid
        file synapseconfig from file(params.synapseconfig)

        output:
        stdout into result

        script:
        """
        echo "synapse -c $synapseconfig store $filepath --parentId $parent"
        synapse -c $synapseconfig store $filepath --parentId $parent
        """

    }
else
    error "Invalid synapse cmd"

if (params.command == "get")
    result.subscribe { println "File: ${it.name}" }
else if (params.command == "store")
    result.subscribe { println it }
