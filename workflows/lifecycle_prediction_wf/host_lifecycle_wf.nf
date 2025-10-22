include { phabox2_host_lifecycle } from './process/phabox2_host_lifecycle_wf'


workflow host_lifecycle_wf {
    main: testprofile()
    emit: testprofile.out.flatten().map { file -> tuple(file.simpleName, file) }

    //host: https://www.biorxiv.org/content/10.1101/2020.12.06.413476v1
}

