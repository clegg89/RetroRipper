cmake_minimum_required(VERSION 3.15.3)

get_directory_property(hasParent PARENT_DIRECTORY)
if(NOT hasParent)
	list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/../../cmake)

	project(RetroRipperDriver C CXX ASM)

	set(CMAKE_C_EXTENSIONS OFF)
endif()

if(NOT RETRO_RIPPER_STM32_PLATFORMS)
	# All Supported Platforms
	set(RETRO_RIPPER_STM32_PLATFORMS STM32F1)
endif()

find_package(STM32 REQUIRED ${RETRO_RIPPER_STM32_PLATFORMS})
find_package(CMSIS REQUIRED ${RETRO_RIPPER_STM32_PLATFORMS})
find_package(HAL REQUIRED ${RETRO_RIPPER_STM32_PLATFORMS})

add_library(RetroRipper::Driver INTERFACE)
target_include_directories(RetroRipper::Driver INTERFACE "${CMAKE_CURRENT_LIST_DIR}/include")

foreach(FAMILY ${RETRO_RIPPER_STM32_PLATFORMS})
	# TODO get family directory FAMILY
	# include sources from that directory
	# add_library(RetroRipper::Driver::${FAMILY} STATIC)
endforeach()
