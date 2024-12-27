require "test_helper"

class GroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:admin) # Usa el fixture de admin
    log_in_as(@admin_user)      # Inicia sesión con el usuario admin

    @principal = principals(:one) # Fixture del principal
    @group_asc = groups(:asc)     # Fixture del grupo ascensor
    @group_sin_items = groups(:extra) # Fixture del grupo sin ítems
    @rule_asc = rules(:asc)       # Fixture de la regla para ascensor
  end

  # --------------------------------------------------
  # TEST: INDEX
  # --------------------------------------------------
  test "should get index" do
    # La acción index en tu GroupsController excluye 'libre', pero tú ya no tienes ninguno
    # Igualmente, probamos que la respuesta sea exitosa y que veamos 'Grupo Ascensor'
    get groups_url
    assert_response :success
    assert_includes @response.body, "Grupo Ascensor"
    # No hay 'libre', así que no lo buscamos
  end

  # --------------------------------------------------
  # TEST: NEW
  # --------------------------------------------------
  test "should get new" do
    get new_group_url
    assert_response :success
  end

  # --------------------------------------------------
  # TEST: SHOW
  # --------------------------------------------------
  test "should show group" do
    # Mostramos el grupo ascensor
    get group_url(@group_asc)
    assert_response :success
    # El controller setea @rules. Comprobamos que aparezca "Verificar algo de ascensor"
    assert_includes @response.body, "Verificar algo de ascensor"
  end

  # --------------------------------------------------
  # TEST: CREATE GROUP
  # --------------------------------------------------
  test "should create group" do
    # Creamos un nuevo grupo ascensor
    assert_difference("Group.count") do
      post groups_url, params: {
        group: { name: "Nuevo Grupo", type_of: "ascensor", number: 10 }
      }
    end
    assert_redirected_to groups_url
    follow_redirect!
    assert_match /Se creó la clasificación con éxito/, flash[:notice]
  end

  # --------------------------------------------------
  # TEST: DUPLICATE ESCALA
  # --------------------------------------------------
  test "should not create duplicate escala group" do
    # Creamos un primer grupo de tipo 'escala'
    Group.create!(name: "Escala Existente", type_of: "escala", number: 99)

    # Intentamos crear otro grupo 'escala'
    assert_no_difference("Group.count") do
      post groups_url, params: {
        group: { name: "Escala Duplicada", type_of: "escala", number: 100 }
      }
    end

    assert_redirected_to new_group_url
    follow_redirect!
    assert_match /Ya existe un grupo con el tipo 'escala'/, flash[:alert]
  end

  # --------------------------------------------------
  # TEST: DESTROY GROUP (que no tiene ítems)
  # --------------------------------------------------
  test "should destroy group" do
    # Intentamos destruir el grupo sin ítems
    assert_difference("Group.count", -1) do
      delete group_url(@group_sin_items)
    end
    assert_redirected_to groups_url
    follow_redirect!
    assert_match /Grupo eliminado con éxito/, flash[:notice]
  end

  # --------------------------------------------------
  # TEST: DESTROY GROUP con items => debería fallar
  # --------------------------------------------------
  test "should not destroy group with items" do
    # Intentamos destruir el grupo ascensor, que tiene un ítem asociado
    assert_no_difference("Group.count") do
      delete group_url(@group_asc)
    end
    assert_redirected_to group_url(@group_asc)
    follow_redirect!
    assert_match /No se pudo eliminar el grupo porque tiene elementos asociados/, flash[:alert]
  end
end
