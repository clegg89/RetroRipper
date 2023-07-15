_stm32_create_family_targets(
	FAMILY WL
	SUBFAMILY M4
)

_stm32_create_family_targets(
	FAMILY WL
	SUBFAMILY M0PLUS
)

target_compile_options(STM32::WL::M4 INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=soft>
)
target_link_options(STM32::WL::M4 INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=soft>
)

target_compile_options(STM32::WL::M0PLUS INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0plus>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=soft>
)
target_link_options(STM32::WL::M0PLUS INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0plus>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=soft>
)
