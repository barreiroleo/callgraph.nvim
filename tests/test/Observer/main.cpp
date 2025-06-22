// Test lua api
// require("callgraph").run({direction = "mix"})
// require("callgraph").run({direction = "mix", filter_location = { "external thing" }})
// require("callgraph").run({direction = "mix"}, {profiling = true})
// require("callgraph").run({direction = "mix"}, {on_start = function() vim.notify("Run") end })
// require("callgraph").run({direction = "mix"}, {on_finish = function() vim.notify("Finished") end })
// require("callgraph").run({direction = "mix"}, {log_level = vim.log.levels.OFF}) -- Pending

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
