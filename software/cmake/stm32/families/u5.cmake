set(STM32_U5_TYPES 
	# STM32U535/STM32U545
	U535xx U545xx
	# STM32U575/STM32U585
	U575xx U585xx
	# STM32U595/STM32U5A5
	U595xx U5A5xx
	# STM32U599/STM32U5A9
	U599xx U5A9xx
)

_stm32_create_family_targets(
	FAMILY
U5
	TYPES
${STM32_U5_TYPES}
)

target_compile_options(STM32::U5 INTERFACE
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m33>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
target_link_options(STM32::U5 INTERFACE
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m33>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
