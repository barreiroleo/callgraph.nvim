#pragma once

#include "ServiceCommon.hpp"

#include "../lib/Bus.hpp"

namespace Services::A {

struct Data {
    int service_id;
    std::string data_from_A;
};

class Service : public Bus::Dispacher<Data> {
public:
    void process()
    {
        run_service_a();
        notify_clients({ .data_from_A = "Hey, here is some data from service A" });
    }

    void run_service_a()
    {
        Common::do_something_common();
    }
};
}
