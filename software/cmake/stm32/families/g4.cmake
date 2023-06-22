set(STM32_G4_TYPES 
	# STM32G4x1 Access Line
	G431xx G441xx G471xx G491xx G4A1xx
	# STM32G4x3 Performance Line
	G473xx G483xx
	# STM32G4x4 Hi-resolution line
	G474xx G484xx
)

_stm32_create_family_targets(
	FAMILY G4
	TYPES ${STM32_G4_TYPES}
)

target_compile_options(STM32::G4 INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv4-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
target_link_options(STM32::G4 INTERFACE 
	$<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m4>
	$<$<C_COMPILER_ID:GNU>:-mfpu=fpv4-sp-d16>
	$<$<C_COMPILER_ID:GNU>:-mfloat-abi=hard>
)
