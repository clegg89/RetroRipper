set(STM32_F1_TYPES 
	# SMT32F100 Value Line
	F100xB F100xE
	# STM32F101
	F101x6 F101xB F101xE F101xG
	# STM32F102
	F102x6 F102xB
	# STM32F103
	F103x6 F103xB F103xE F103xG
	# STM32F105/STM32F107
	F105xC F107xC
)

_stm32_create_family_targets(
	FAMILY F1
	TYPES ${STM32_F1_TYPES}
)

target_compile_options(STM32::F1 INTERFACE
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m3>
)

target_link_options(STM32::F1 INTERFACE
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m3>
)
