#pragma once

#include <iostream>

namespace Services::Common {

static bool do_something_common()
{
    std::cout << "Common functionality executed.\n";
    return true;
}

static bool do_something_common_nested(int a, int b)
{
    return do_something_common();
};

};
