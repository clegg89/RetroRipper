_stm32_create_family_targets(FAMILY F3)

target_compile_options(STM32::F3 INTERFACE
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv4-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
target_link_options(STM32::F3 INTERFACE
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv4-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
