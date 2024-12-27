require "test_helper"

class RuletypesControllerTest < ActionDispatch::IntegrationTest
  setup do

    @admin_user = users(:admin) # Usa el fixture de admin
    log_in_as(@admin_user)      # Inicia sesión con el usuario admin
    # Creamos un Ruletype inicial para nuestras pruebas
    @ruletype = Ruletype.create!(
      rtype: "Comprobación inicial",
      gygatype: "1. CAJA DE ELEVADORES.",
      gygatype_number: "1.1"
    )
  end

  test "should get index" do
    get ruletypes_url
    assert_response :success
    # Opcional: podemos verificar que aparezca el texto de nuestro @ruletype.rtype
    assert_includes @response.body, "Comprobación inicial"
  end

  test "should get new" do
    get new_ruletype_url
    assert_response :success
  end

  test "should create ruletype" do
    # Verificamos que se incremente el conteo de Ruletype al crearlo
    assert_difference("Ruletype.count") do
      post ruletypes_url, params: {
        ruletype: {
          rtype:            "Nueva comprobación",
          gygatype:         "3. PUERTA DE PISO.",
          gygatype_number:  "003"
        }
      }
    end
    # Debe redirigir al index y mostrar el flash de éxito
    assert_redirected_to ruletypes_url
    follow_redirect!
    assert_match /Tipo de regla creada/, flash[:notice]
  end

  test "should create placeholder ruletype" do
    # Si el rtype es "placeholder", según tu lógica, ajusta gygatype y gygatype_number a "100"
    assert_difference("Ruletype.count") do
      post ruletypes_url, params: {
        ruletype: {
          rtype:            "placeholder", # <- fuerza la lógica del controller
          gygatype:         "",            # se sobreescribirá a "100"
          gygatype_number:  ""             # se sobreescribirá a "100"
        }
      }
    end
    assert_redirected_to ruletypes_url
    follow_redirect!
    # Podemos verificar que se guardó como "100"
    created_rt = Ruletype.order(:id).last
    assert_equal "100", created_rt.gygatype
    assert_equal "100.1", created_rt.gygatype_number
    assert_match /Tipo de regla creada/, flash[:notice]
  end

  test "should show ruletype" do
    get ruletype_url(@ruletype)
    assert_response :success
    # Confirmamos que el cuerpo incluya el texto de la comprobación
    assert_includes @response.body, @ruletype.rtype
  end

  test "should destroy ruletype" do
    # Al eliminar, el count debe decrementar en 1
    assert_difference("Ruletype.count", -1) do
      delete ruletype_url(@ruletype)
    end
    assert_redirected_to ruletypes_url
    follow_redirect!
    assert_match /Tipo de regla eliminada/, flash[:notice]
  end

  # -- Tests extra para las acciones de importación --

  test "should get new_import" do
    get new_import_ruletypes_url
    assert_response :success
  end

  test "should not import if ruletype already exists" do
    # Ya existe @ruletype, por lo que se activará la condición Ruletype.exists?
    post import_ruletypes_url, params: { file: nil }  # O con un archivo cualquiera
    assert_redirected_to new_import_ruletypes_url
    follow_redirect!
    # El controller revisa si hay Ruletype y lanza flash[:alert] = "Ya existen comprobaciones"
    assert_match /Ya existen comprobaciones/, flash[:alert]
  end

end
