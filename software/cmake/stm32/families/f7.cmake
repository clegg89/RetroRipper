_stm32_create_family_targets(
	FAMILY F7
	SUBFAMILY SP
)

_stm32_create_family_targets(
	FAMILY F7
	SUBFAMILY DP
)

target_compile_options(STM32::F7::SP INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m7>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
target_link_options(STM32::F7::SP INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m7>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)

target_compile_options(STM32::F7::DP INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m7>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
target_link_options(STM32::F7::DP INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m7>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv5-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
