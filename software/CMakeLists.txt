cmake_minimum_required(VERSION 3.15.3)

if(NOT CMAKE_TOOLCHAIN_FILE)
	set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_LIST_DIR}/cmake/toolchain/arm-none-eabi-gcc.cmake)
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

project(RetroRipper C CXX ASM)

set(CMAKE_C_EXTENSIONS OFF)

set(RETRO_RIPPER_STM32_PLATFORMS STM32F1)

add_subdirectory(driver)
add_subdirectory(app)
add_subdirectory(ripper)
add_subdirectory(test)
