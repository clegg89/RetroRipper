_stm32_create_family_targets(FAMILY L1)

target_compile_options(STM32::L1 INTERFACE
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m3>
)
target_link_options(STM32::L1 INTERFACE
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m3>
)
