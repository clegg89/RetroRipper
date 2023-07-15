_stm32_create_family_targets(FAMILY F2)

target_compile_options(STM32::F2 INTERFACE
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m3>
)

target_link_options(STM32::F2 INTERFACE
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m3>
)
