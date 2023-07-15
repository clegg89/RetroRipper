_stm32_create_family_targets(FAMILY F0)

target_compile_options(STM32::F0 INTERFACE
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0>
)

target_link_options(STM32::F0 INTERFACE
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0>
)
