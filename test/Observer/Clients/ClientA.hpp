#pragma once

#include "../Services/ServiceA.hpp"
#include "../lib/Bus.hpp"

#include <memory>

namespace Services::A {

class Client : public Bus::IObserver<Data> {
public:
    auto notify(const Data& data) const -> Bus::Status
    {
        *m_cache_data = data;
        return Bus::Status::OK;
    }

private:
    std::unique_ptr<Data> m_cache_data { std::make_unique<Data>() };
};

}
