set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR ARM)

if (MINGW OR CYGWIN OR WIN32)
	set(UTIL_SEARCH_CMD where)
elseif(UNIX OR APPLE)
	set(UTIL_SEARCH_CMD which)
endif()

set(TOOLCHAIN_PREFIX arm-none-eabi-)

execute_process(
	COMMAND ${UTIL_SEARCH_CMD} ${TOOLCHAIN_PREFIX}gcc
	OUTPUT_VARIABLE BINUTILS_PATH
	OUTPUT_STRIP_TRAILING_WHITESPACE
)

get_filename_component(ARM_TOOLCHAIN_DIR ${BINUTILS_PATH} DIRECTORY)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_ASM_COMPILER ${CMAKE_C_COMPILER})
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}g++)

set(CMAKE_OBJCOPY ${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}objcopy CACHE INTERNAL "objcopy tool")
set(CMAKE_SIZE_UTIL ${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}size CACHE INTERNAL "size tool")

set(CMAKE_FIND_ROOT_PATH ${BINUTILS_PATH})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

set(CMAKE_EXECUTABLE_SUFFIX_C   .elf)
set(CMAKE_EXECUTABLE_SUFFIX_CXX .elf)
set(CMAKE_EXECUTABLE_SUFFIX_ASM .elf)

## Add a linker script to a provided target, with the provided visibility
#
# SCRIPT_BASE The base name of the script, without the file extension
# SCRIPT_DIR A directory with linker scripts for multiple toolchains.
# Each toolchain should have a directory with its own linker scripts
# (i.e. GCC, EWARM, etc.)
function(toolchain_add_linker_script TARGET VISIBILITY SCRIPT_DIR SCRIPT_BASE)
	get_filename_component(SCRIPT_DIR "${SCRIPT_DIR}" ABSOLUTE)

	find_file(SCRIPT
		"${SCRIPT_BASE}.ld"
		PATHS "${SCRIPT_DIR}/GCC"
		NO_CMAKE_PATH
		REQUIRED
	)

	target_link_options(${TARGET} ${VISIBILITY}
		-T "${SCRIPT}"
	)

	# Add the script to the target link dependencies
	get_target_property(TARGET_TYPE ${TARGET} TYPE)
	if(TARGET_TYPE STREQUAL "INTERFACE_LIBRARY")
		set(INTERFACE_PREFIX "INTERFACE_")
	endif()

	get_target_property(LINK_DEPENDS ${TARGET} ${INTERFACE_PREFIX}LINK_DEPENDS)
	if(LINK_DEPENDS)
		list(APPEND LINK_DEPENDS "${SCRIPT}")
	else()
		set(LINK_DEPENDS "${SCRIPT}")
	endif()

	set_target_properties(${TARGET} PROPERTIES ${INTERFACE_PREFIX}LINK_DEPENDS "${LINK_DEPENDS}")
endfunction()

## Add an assembly file to a given target, with the given visibility
#
# SOURCE_BASES List of source base names without file extensions
# SOURCE_DIR A directory with assembly files for multiple toolchains.
# Each toolchain should have a directory with its own source files
# (i.e. GCC, EWARM, etc.)
function(toolchain_add_asm_source TARGET VISIBILITY SOURCE_DIR SOURCE_BASES)
	get_filename_component(SOURCE_DIR "${SOURCE_DIR}" ABSOLUTE)

	foreach(SOURCE_BASE ${SOURCE_BASES})
		find_file(SOURCE
			"${SOURCE_BASE}.s"
			PATHS "${SOURCE_DIR}/GCC"
			NO_CMAKE_PATH
			REQUIRED
		)

		list(APPEND SOURCES ${SOURCE})
	endforeach()

	target_sources(${TARGET} ${VISIBILITY} ${SOURCES})
endfunction()

## Generate a map file for the given target
function(toolchain_add_map_file TARGET)
	set(MAP_FILE_OUTPUT "$<TARGET_FILE_DIR:${TARGET}>/$<TARGET_FILE_BASE_NAME:${TARGET}>.map")
	target_link_options(${TARGET} PRIVATE -Wl,-Map,${MAP_FILE_OUTPUT})
endfunction()

## GCC does not have equivalent to IAR's log output
function(toolchain_add_linker_log_output TARGET)
endfunction()
