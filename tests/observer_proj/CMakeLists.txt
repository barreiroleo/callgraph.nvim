cmake_minimum_required(VERSION 3.28)
project(observer_pattern)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(observer_app main.cpp)

target_include_directories(observer_app PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/lib
    ${CMAKE_CURRENT_SOURCE_DIR}/Services
    ${CMAKE_CURRENT_SOURCE_DIR}/Clients
)

# Diagnostic warnings
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(observer_app PRIVATE -Wall -Wextra -Wpedantic)
elseif(MSVC)
    target_compile_options(observer_app PRIVATE /W4)
endif()
