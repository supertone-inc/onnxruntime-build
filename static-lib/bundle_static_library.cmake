# References:
# ../onnxruntime/cmake/onnxruntime_webassembly.cmake
# - https://cristianadam.eu/20190501/bundling-together-static-libraries-with-cmake

function(bundle_static_library bundled_target_name)
    function(recursively_collect_dependencies input_target)
        set(input_link_libraries LINK_LIBRARIES)
        get_target_property(input_type ${input_target} TYPE)

        if(${input_type} STREQUAL "INTERFACE_LIBRARY")
            set(input_link_libraries INTERFACE_LINK_LIBRARIES)
        endif()

        get_target_property(public_dependencies ${input_target} ${input_link_libraries})

        foreach(dependency IN LISTS public_dependencies)
            if(TARGET ${dependency})
                get_target_property(alias ${dependency} ALIASED_TARGET)

                if(TARGET ${alias})
                    set(dependency ${alias})
                endif()

                get_target_property(type ${dependency} TYPE)

                if(${type} STREQUAL "STATIC_LIBRARY")
                    list(APPEND static_libs ${dependency})
                endif()

                get_property(library_already_added GLOBAL PROPERTY ${target_name}_static_bundle_${dependency})

                if(NOT library_already_added)
                    set_property(GLOBAL PROPERTY ${target_name}_static_bundle_${dependency} ON)
                    recursively_collect_dependencies(${dependency})
                endif()
            endif()
        endforeach()

        set(static_libs ${static_libs} PARENT_SCOPE)
    endfunction()

    foreach(target_name IN ITEMS ${ARGN})
        list(APPEND static_libs ${target_name})
        recursively_collect_dependencies(${target_name})
    endforeach()

    list(REMOVE_DUPLICATES static_libs)

    set(bundled_target_full_name
        ${CMAKE_BINARY_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}${bundled_target_name}${CMAKE_STATIC_LIBRARY_SUFFIX})

    if(MSVC)
        foreach(target IN LISTS static_libs)
            list(APPEND static_lib_full_names $<TARGET_FILE:${target}>)
        endforeach()

        set(lib ${CMAKE_AR})

        add_custom_command(
            COMMAND ${lib} /NOLOGO /OUT:${bundled_target_full_name} ${static_lib_full_names}
            OUTPUT ${bundled_target_full_name}
            COMMENT "Bundling ${bundled_target_name}"
            VERBATIM)
    elseif(APPLE)
        foreach(target IN LISTS static_libs)
            list(APPEND static_lib_full_names $<TARGET_FILE:${target}>)
        endforeach()

        find_program(libtool libtool)

        add_custom_command(
            COMMAND ${libtool} -static -o ${bundled_target_full_name} ${static_lib_full_names}
            OUTPUT ${bundled_target_full_name}
            COMMENT "Bundling ${bundled_target_name}"
            VERBATIM)
    else()
        file(WRITE ${CMAKE_BINARY_DIR}/${bundled_target_name}.ar.in
            "CREATE ${bundled_target_full_name}\n")

        foreach(target IN LISTS static_libs)
            file(APPEND ${CMAKE_BINARY_DIR}/${bundled_target_name}.ar.in
                "ADDLIB $<TARGET_FILE:${target}>\n")
        endforeach()

        file(APPEND ${CMAKE_BINARY_DIR}/${bundled_target_name}.ar.in "SAVE\n")
        file(APPEND ${CMAKE_BINARY_DIR}/${bundled_target_name}.ar.in "END\n")

        file(GENERATE
            OUTPUT ${CMAKE_BINARY_DIR}/${bundled_target_name}.ar
            INPUT ${CMAKE_BINARY_DIR}/${bundled_target_name}.ar.in)

        set(ar ${CMAKE_AR})

        if(CMAKE_INTERPROCEDURAL_OPTIMIZATION)
            set(ar ${CMAKE_CXX_COMPILER_AR})
        endif()

        add_custom_command(
            COMMAND ${ar} -M < ${CMAKE_BINARY_DIR}/${bundled_target_name}.ar
            OUTPUT ${bundled_target_full_name}
            COMMENT "Bundling ${bundled_target_name}"
            VERBATIM)
    endif()

    add_custom_target(bundling_target ALL DEPENDS ${bundled_target_full_name})

    foreach(target_name IN ITEMS ${ARGN})
        add_dependencies(bundling_target ${target_name})
    endforeach()

    add_library(${bundled_target_name} STATIC IMPORTED GLOBAL)
    set_target_properties(${bundled_target_name}
        PROPERTIES
        IMPORTED_LOCATION ${bundled_target_full_name})

    foreach(target_name IN ITEMS ${ARGN})
        set_property(TARGET ${bundled_target_name} APPEND
            PROPERTY INTERFACE_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:${target_name},INTERFACE_INCLUDE_DIRECTORIES>)
        set_property(TARGET ${bundled_target_name} APPEND
            PROPERTY INTERFACE_COMPILE_DEFINITIONS $<TARGET_PROPERTY:${target_name},INTERFACE_COMPILE_DEFINITIONS>)
    endforeach()

    add_dependencies(${bundled_target_name} bundling_target)
endfunction()
