defmodule Jabbax.SerializerTest do
  use ExUnit.Case
  use Jabbax.Document
  alias Jabbax.Serializer

  test "one resource, attributes, relationships, meta, links and includes" do
    assert Serializer.call(%Document{
             data: %Resource{
               type: "employees",
               id: 1,
               attributes: %{
                 "name" => "Some guy",
                 :days_active => 123
               },
               relationships: %{
                 "supported_services" => [
                   %ResourceId{type: "service_pricing_levels", id: 11},
                   %ResourceId{type: "service_pricing_levels", id: "12"}
                 ]
               },
               links: %{
                 self: "http://example.com/employees/1",
                 related: %Link{
                   href: "http://example.com/employees/1/profile",
                   meta: %{
                     "age" => 21
                   }
                 }
               }
             },
             meta: %{
               :numeric_meta => 1,
               "numeric_decimal_meta" => 1.75,
               "string_meta" => "string_value",
               "nil_meta" => nil
             },
             included: [
               %Resource{
                 type: :service_pricing_levels,
                 id: 11,
                 relationships: %{
                   service: %Relationship{
                     data: %ResourceId{
                       type: :services,
                       id: 21
                     },
                     links: %{
                       self: "http://example.com/services/21"
                     },
                     meta: %{
                       x: 1
                     }
                   }
                 }
               }
             ]
           }) == %{
             data: %{
               type: "employees",
               id: "1",
               attributes: %{
                 "name" => "Some guy",
                 "days-active" => 123
               },
               relationships: %{
                 "supported-services" => %{
                   data: [
                     %{type: "service-pricing-levels", id: "11"},
                     %{type: "service-pricing-levels", id: "12"}
                   ]
                 }
               },
               links: %{
                 "self" => "http://example.com/employees/1",
                 "related" => %{
                   href: "http://example.com/employees/1/profile",
                   meta: %{
                     "age" => 21
                   }
                 }
               }
             },
             meta: %{
               "numeric-meta" => 1,
               "numeric-decimal-meta" => 1.75,
               "string-meta" => "string_value",
               "nil-meta" => nil
             },
             included: [
               %{
                 type: "service-pricing-levels",
                 id: "11",
                 relationships: %{
                   "service" => %{
                     data: %{
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
    assert Serializer.call(%Document{
             data: [
               %Resource{
                 type: "employees",
                 id: 1,
                 attributes: %{
                   "name" => "Some guy",
                   "days_active" => 123
                 }
               },
               %Resource{
                 type: "employees",
                 id: 2,
                 attributes: %{
                   "name" => "Other guy",
                   "days_active" => 234
                 }
               }
             ]
           }) == %{
             data: [
               %{
                 type: "employees",
                 id: "1",
                 attributes: %{
                   "name" => "Some guy",
                   "days-active" => 123
                 }
               },
               %{
                 type: "employees",
                 id: "2",
                 attributes: %{
                   "name" => "Other guy",
                   "days-active" => 234
                 }
               }
             ],
             jsonapi: %{
               version: "1.0"
             }
           }
  end

  test "recursive attributes" do
    assert Serializer.call(%Document{
             data: %Resource{
               type: "employees",
               id: 1,
               attributes: %{
                 "name" => "Some guy",
                 "embedded_settings" => %{
                   "some_setting" => 123,
                   :other_setting => [
                     %{"one_digit" => 1},
                     %{:two_digit => 2}
                   ]
                 }
               },
               meta: %{
                 "embedded_meta" => %{
                   "some_meta" => 999
                 }
               }
             }
           }) == %{
             data: %{
               type: "employees",
               id: "1",
               attributes: %{
                 "name" => "Some guy",
                 "embedded-settings" => %{
                   "some-setting" => 123,
                   "other-setting" => [
                     %{"one-digit" => 1},
                     %{"two-digit" => 2}
                   ]
                 }
               },
               meta: %{
                 "embedded-meta" => %{
                   "some-meta" => 999
                 }
               }
             },
             jsonapi: %{
               version: "1.0"
             }
           }
  end

  defmodule Decimal do
    defstruct [:value]
  end

  test "passing struct attributes unchanged" do
    assert Serializer.call(%Document{
             data: %Resource{
               type: "employees",
               id: 1,
               attributes: %{
                 age: %Decimal{value: 30}
               }
             }
           }) == %{
             data: %{
               type: "employees",
               id: "1",
               attributes: %{
                 "age" => %Decimal{value: 30}
               }
             },
             jsonapi: %{
               version: "1.0"
             }
           }
  end

  test "empty data" do
    assert Serializer.call(%Document{data: nil}) == %{
             data: nil,
             jsonapi: %{
               version: "1.0"
             }
           }

    assert Serializer.call(%Document{
             data: %Resource{
               id: "1",
               type: "employees",
               relationships: %{
                 business: %Relationship{
                   data: nil
                 }
               }
             },
             jsonapi: %{
               version: "1.0"
             }
           }) == %{
             data: %{
               id: "1",
               type: "employees",
               relationships: %{
                 "business" => %{
                   data: nil
                 }
               }
             },
             jsonapi: %{
               version: "1.0"
             }
           }
  end

  test "errors" do
    assert Serializer.call(%Document{
             errors: [
               %Error{
                 code: :internal_server_error
               },
               %Error{
                 code: "invalid_query_parameter",
                 source: %ErrorSource{parameter: "include[first_name]"}
               },
               %Error{
                 code: "invalid_document",
                 source: %ErrorSource{pointer: "/data/attributes/email_address"}
               }
             ]
           }) == %{
             errors: [
               %{
                 code: "internal-server-error"
               },
               %{
                 code: "invalid-query-parameter",
                 source: %{
                   parameter: "include[first-name]"
                 }
               },
               %{
                 code: "invalid-document",
                 source: %{
                   pointer: "/data/attributes/email-address"
                 }
               }
             ],
             jsonapi: %{
               version: "1.0"
             }
           }
  end

  describe "error status normalization for 422" do
    # Phoenix 1.6 renamed HTTP 422 from "Unprocessable Entity" to "Unprocessable Content" (RFC 9110).
    # 35+ repos across the org depend on "unprocessable-entity" string, so we hardcode it.

    test "normalizes unprocessable-entity string" do
      assert %{errors: [%{status: "unprocessable-entity"}]} =
               Serializer.call(%Document{errors: [%Error{status: "unprocessable-entity"}]})
    end

    test "normalizes unprocessable_entity string" do
      assert %{errors: [%{status: "unprocessable-entity"}]} =
               Serializer.call(%Document{errors: [%Error{status: "unprocessable_entity"}]})
    end

    test "normalizes Unprocessable-Entity string (case insensitive)" do
      assert %{errors: [%{status: "unprocessable-entity"}]} =
               Serializer.call(%Document{errors: [%Error{status: "Unprocessable-Entity"}]})
    end

    test "normalizes unprocessable-content string (Phoenix 1.6+)" do
      assert %{errors: [%{status: "unprocessable-entity"}]} =
               Serializer.call(%Document{errors: [%Error{status: "unprocessable-content"}]})
    end

    test "normalizes unprocessable_content string (Phoenix 1.6+)" do
      assert %{errors: [%{status: "unprocessable-entity"}]} =
               Serializer.call(%Document{errors: [%Error{status: "unprocessable_content"}]})
    end

    test "normalizes Unprocessable_Content string (case insensitive)" do
      assert %{errors: [%{status: "unprocessable-entity"}]} =
               Serializer.call(%Document{errors: [%Error{status: "Unprocessable_Content"}]})
    end

    test "normalizes :unprocessable_entity atom" do
      assert %{errors: [%{status: "unprocessable-entity"}]} =
               Serializer.call(%Document{errors: [%Error{status: :unprocessable_entity}]})
    end

    test "normalizes :unprocessable_content atom (Phoenix 1.6+)" do
      assert %{errors: [%{status: "unprocessable-entity"}]} =
               Serializer.call(%Document{errors: [%Error{status: :unprocessable_content}]})
    end

    test "preserves other status strings unchanged" do
      assert %{errors: [%{status: "not-found"}]} =
               Serializer.call(%Document{errors: [%Error{status: "not-found"}]})

      assert %{errors: [%{status: "internal_server_error"}]} =
               Serializer.call(%Document{errors: [%Error{status: "internal_server_error"}]})
    end

    test "converts integer status to string" do
      assert %{errors: [%{status: "422"}]} =
               Serializer.call(%Document{errors: [%Error{status: 422}]})
    end

    test "handles nil status" do
      result = Serializer.call(%Document{errors: [%Error{code: "some-error"}]})
      refute Map.has_key?(hd(result.errors), :status)
    end
  end
end
