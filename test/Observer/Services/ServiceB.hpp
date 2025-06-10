#pragma once

#include "ServiceCommon.hpp"

#include "../lib/Bus.hpp"

namespace Services::B {

struct Data {
    std::string service_name;
    std::string data_from_b {};
};

class Service : public Bus::Dispacher<Data> {
public:
    void process()
    {
        run_service_b();
        notify_clients({ .data_from_b = "Hey, here is some data from service B" });
    }

    void run_service_b()
    {
        Common::do_something_common_nested(1, 2);
    }
};
}
