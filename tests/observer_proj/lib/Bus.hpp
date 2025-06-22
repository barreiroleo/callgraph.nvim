#pragma once

#include <iostream>
#include <vector>

namespace Bus {

enum class Status {
    OK,
    ERR,
};

///
/// @brief Observer interface required by the Dispacher
///
template <typename TData>
class IObserver {
public:
    virtual auto notify(const TData& data) const -> Status = 0;
};

///
/// @brief Dispacher implementation for Observer pattern
///
/// @tparam TData Data structure that will be passed to observers
///
template <typename TData>
class Dispacher {
public:
    void subscribe(IObserver<TData>& client)
    {
        std::cout << "Subscribing client\n";
        m_clients.push_back(&client);
    }

    void notify_clients(const TData&& data)
    {
        for (const auto& client : m_clients) {
            std::cout << "Notifying client\n";

            if (client->notify(data) != Status::OK) {
                std::cout << "Error notifying client\n";
            }
        }
    }

private:
    std::vector<IObserver<TData>*> m_clients;
};

}
