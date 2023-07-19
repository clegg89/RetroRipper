cmake_minimum_required(VERSION 3.15.3)

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_LIST_DIR}/../../cmake/toolchain/arm-none-eabi-gcc.cmake)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/../../cmake)

project(RetroRipper C CXX ASM)

set(CMAKE_C_EXTENSIONS OFF)

find_package(STM32 REQUIRED STM32F1)
find_package(CMSIS REQUIRED STM32F103RB)
find_package(HAL REQUIRED STM32F1)

cmsis_stm32_get_device_type("F103RB" DEVICE_TYPE)

set(SOURCES
	src/main.cpp
	src/stm32f1xx_it.c
	src/stm32f1xx_hal_msp.c
	src/system_stm32f1xx.c  
)

add_executable(${PROJECT_NAME} ${SOURCES})

target_compile_features(${PROJECT_NAME} PUBLIC c_std_99 cxx_std_20)

target_include_directories(${PROJECT_NAME} PUBLIC "${CMAKE_CURRENT_LIST_DIR}/include")
target_link_libraries(${PROJECT_NAME} PUBLIC
	HAL::STM32::F1::GPIOEx
	HAL::STM32::F1::TIMEx
	HAL::STM32::F1::UART
	HAL::STM32::F1::RCCEx
	HAL::STM32::F1::DMA
	HAL::STM32::F1::CORTEX
	HAL::STM32::F1::PWR
	HAL::STM32::F1::FLASHEx
	HAL::STM32::F1::EXTI
	STM32::Nano
	CMSIS::STM32::${DEVICE_TYPE}
)

toolchain_add_asm_source(${PROJECT_NAME} PUBLIC "${CMAKE_CURRENT_LIST_DIR}/toolchain" "startup_stm32f103xb")
toolchain_add_linker_script(${PROJECT_NAME} PUBLIC "${CMAKE_CURRENT_LIST_DIR}/toolchain" "STM32F103RBTx_FLASH")
toolchain_add_map_file(${PROJECT_NAME})
toolchain_add_linker_log_output(${PROJECT_NAME})

# Print executable size
add_custom_command(TARGET ${PROJECT_NAME}
	POST_BUILD
	COMMAND ${CMAKE_SIZE_UTIL} $<TARGET_FILE:${PROJECT_NAME}>)

# Create hex file
add_custom_command(TARGET ${PROJECT_NAME}
	POST_BUILD
	COMMAND ${TOOLCHAIN_HEX_COMMAND} $<TARGET_FILE:${PROJECT_NAME}> ${PROJECT_NAME}.hex
	COMMAND ${TOOLCHAIN_BIN_COMMAND} $<TARGET_FILE:${PROJECT_NAME}> ${PROJECT_NAME}.bin)
