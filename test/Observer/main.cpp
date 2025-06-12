#include "Clients/ClientA.hpp"
#include "Services//ServiceA.hpp"

#include "Clients/ClientB.hpp"
#include "Services/ServiceB.hpp"

void run_test_a()
{
    Services::A::Service service {};
    Services::A::Client client {};

    service.subscribe(client);

    service.process();
}

void run_test_b()
{
    Services::B::Service service {};
    Services::B::Client client {};

    service.subscribe(client);
    service.process();
}

int main()
{
    run_test_a();
    run_test_b();
}
