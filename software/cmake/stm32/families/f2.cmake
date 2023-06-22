set(STM32_F2_TYPES 
	# STM32F205/ST32F215
	F205xx F215xx
	# STM32F207/STM32F217
	F207xx F217xx
)

stm32_create_family_targets(
	FAMILY F2
	TYPES ${STM32_F2_TYPES}
)

target_compile_options(STM32::F2 INTERFACE
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m3>
)

target_link_options(STM32::F2 INTERFACE
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m3>
)
