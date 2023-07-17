set(STM32_G0_COMPILE_OPTIONS
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0plus>
)

set(STM32_G0_LINK_OPTIONS
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0plus>
)
