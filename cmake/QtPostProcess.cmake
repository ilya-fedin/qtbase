function(qt_internal_write_depends_file target)
    set(module Qt${target})
    set(outfile "${PROJECT_BINARY_DIR}/include/${module}/${module}Depends")
    message("Generate ${outfile}...")
    set(contents "/* This file was generated by cmake with the info from ${module} target. */\n")
    string(APPEND contents "#ifdef __cplusplus /* create empty PCH in C mode */\n")
    foreach (m ${ARGN})
        string(APPEND contents "#  include <Qt${m}/Qt${m}>\n")
    endforeach()
    string(APPEND contents "#endif\n")

    file(GENERATE OUTPUT "${outfile}" CONTENT "${contents}")
endfunction()

function(qt_internal_create_depends_files)
    message("Generating depends files for ${KNOWN_QT_MODULES}...")
    foreach (target ${KNOWN_QT_MODULES})
        get_target_property(depends "${target}" LINK_LIBRARIES)
        foreach (dep ${depends})
            # Normalize module by stripping leading "Qt::" and trailing "Private"
            if (dep MATCHES "Qt::(.*)")
                set(dep "${CMAKE_MATCH_1}")
            endif()
            if (dep MATCHES "(.*)Private")
                set(dep "${CMAKE_MATCH_1}")
            endif()

            list(FIND KNOWN_QT_MODULES "${dep}" _pos)
            if (_pos GREATER -1)
                list(APPEND qtdeps "${dep}")
            endif()
        endforeach()

        if (DEFINED qtdeps)
            list(REMOVE_DUPLICATES qtdeps)
        endif()

        get_target_property(hasModuleHeaders "${target}" MODULE_HAS_HEADERS)
        if (${hasModuleHeaders})
            qt_internal_write_depends_file("${target}" ${qtdeps})
        endif()
    endforeach()
endfunction()

qt_internal_create_depends_files()
