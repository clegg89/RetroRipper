set(STM32_L5_TYPES 
	# STM32L552 USB Device & CAN-FD
	L552xx
	# STM32L562 USB Device & CAND-FD & AES
	L562xx
)

stm32_create_family_targets(
	FAMILY L5
	TYPES ${STM32_L5_TYPES}
)

target_compile_options(STM32::L5 INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m33>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
target_link_options(STM32::L5 INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m33>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
