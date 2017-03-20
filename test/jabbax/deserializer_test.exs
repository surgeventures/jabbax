defmodule Jabbax.DeserializerTest do
  use ExUnit.Case
  use Jabbax.Document
  alias Jabbax.Deserializer

  test "one resource, attributes, relationships, meta, links and includes" do
    assert Deserializer.call(
      %{
        "data" => %{
          "type" => "employees",
          "id" => "1",
          "attributes" => %{
            "name" => "Some guy",
            "days-active" => 123
          },
          "relationships" => %{
            "supported-services" => %{
              "data" => [
                %{"type" => "service-pricing-levels", "id" => "11"},
                %{"type" => "service-pricing-levels", "id" => "12"}
              ]
            }
          },
          "links" => %{
            "self" => "http://example.com/employees/1",
            "related" => %{
              "href" => "http://example.com/employees/1/profile",
              "meta" => %{
                "age" => 21
              }
            }
          }
        },
        "meta" => %{
          "numeric-meta" => 1,
          "numeric-decimal-meta" => 1.75,
          "string-meta" => "string_value",
          "nil-meta" => nil,
        },
        "included" => [
          %{
            "type" => "service-pricing-levels",
            "id" => "11",
            "relationships" => %{
              "service" => %{
                "data" => %{
                  "type" => "services",
                  "id" => "21"
                },
                "links" => %{
                  "self" => "http://example.com/services/21"
                },
                "meta" => %{
                  "x" => 1
                }
              }
            }
          }
        ],
        "jsonapi" => %{
          "version" => "1.0"
        }
      }
    ) == %Document{
      data: %Resource{
        type: "employees",
        id: "1",
        attributes: %{
          "name" => "Some guy",
          "days_active" => 123
        },
        relationships: %{
          "supported_services" => [
            %ResourceId{type: "service_pricing_levels", id: "11"},
            %ResourceId{type: "service_pricing_levels", id: "12"}
          ]
        },
        links: %{
          "self" => "http://example.com/employees/1",
          "related" => %Link{
            href: "http://example.com/employees/1/profile",
            meta: %{
              "age" => 21
            }
          }
        }
      },
      meta: %{
        "numeric_meta" => 1,
        "numeric_decimal_meta" => 1.75,
        "string_meta" => "string_value",
        "nil_meta" => nil
      },
      included: [
        %Resource{
          type: "service_pricing_levels",
          id: "11",
          relationships: %{
            "service" => %Relationship{
              data: %ResourceId{
                type: "services",
                id: "21"
              },
              links: %{
                "self" => "http://example.com/services/21"
              },
              meta: %{
                "x" => 1
              }
            }
          }
        }
      ],
      jsonapi: %{
        version: "1.0"
      }
    }
  end

  test "multiple resources" do
    assert Deserializer.call(
      %{
        "data" => [
          %{
            "type" => "employees",
            "id" => "1",
            "attributes" => %{
              "name" => "Some guy",
              "days-active" => 123
            }
          },
          %{
            "type" => "employees",
            "id" => "2",
            "attributes" => %{
              "name" => "Other guy",
              "days-active" => 234
            }
          }
        ],
        "jsonapi" => %{
          "version" => "1.0"
        }
      }
    ) == %Document{
      data: [
        %Resource{
          type: "employees",
          id: "1",
          attributes: %{
            "name" => "Some guy",
            "days_active" => 123
          }
        },
        %Resource{
          type: "employees",
          id: "2",
          attributes: %{
            "name" => "Other guy",
            "days_active" => 234
          }
        }
      ],
      jsonapi: %{
        version: "1.0"
      }
    }
  end

  test "recursive attributes" do
    assert Deserializer.call(
      %{
        "data" => %{
          "type" => "employees",
          "id" => "1",
          "attributes" => %{
            "name" => "Some guy",
            "embedded-settings" => %{
              "some-setting" => 123,
              "other-setting" => [
                %{"one-digit" => 1},
                %{"two-digit" => 2}
              ]
            }
          },
          "meta" => %{
            "embedded-meta" => %{
              "some-meta" => 999
            }
          }
        },
        "jsonapi" => %{
          "version" => "1.0"
        }
      }
    ) == %Document{
      data: %Resource{
        type: "employees",
        id: "1",
        attributes: %{
          "name" => "Some guy",
          "embedded_settings" => %{
            "some_setting" => 123,
            "other_setting" => [
              %{"one_digit" => 1},
              %{"two_digit" => 2}
            ]
          }
        },
        meta: %{
          "embedded_meta" => %{
            "some_meta" => 999
          }
        }
      },
      jsonapi: %{
        version: "1.0"
      }
    }
  end

  test "empty data" do
    assert Deserializer.call(
      %{
        "data" => nil,
        "jsonapi" => %{
          "version" => "1.0"
        }
      }
    ) == %Document{
      data: nil,
      jsonapi: %{
        version: "1.0"
      }
    }
  end

  test "errors" do
    assert Deserializer.call(
      %{
        "errors" => [
          %{
            "code" => "internal-server-error"
          },
          %{
            "code" => "invalid-query-parameter",
            "source" => %{
              "parameter" => "include[first-name]"
            }
          },
          %{
            "code" => "invalid-document",
            "source" => %{
              "pointer" => "/data/attributes/email-address"
            }
          }
        ],
        "jsonapi" => %{
          "version" => "1.0"
        }
      }
    ) == %Document{
      errors: [
        %Error{
          code: "internal_server_error",
        },
        %Error{
          code: "invalid_query_parameter",
          source: %ErrorSource{parameter: "include[first_name]"}
        },
        %Error{
          code: "invalid_document",
          source: %ErrorSource{pointer: "/data/attributes/email_address"}
        }
      ],
      jsonapi: %{
        version: "1.0"
      }
    }
  end
end
