require "application_system_test_case"

class ReportsTest < ApplicationSystemTestCase
  setup do
    @report = reports(:one)
  end

  test "visiting the index" do
    visit reports_url
    assert_selector "h1", text: "Reports"
  end

  test "should create report" do
    visit reports_url
    click_on "New report"

    fill_in "Certificado minvu", with: @report.certificado_minvu
    fill_in "Ea rol", with: @report.ea_rol
    fill_in "Ea rut", with: @report.ea_rut
    fill_in "Em rol", with: @report.em_rol
    fill_in "Em rut", with: @report.em_rut
    fill_in "Empresa anterior", with: @report.empresa_anterior
    fill_in "Empresa mantenedora", with: @report.empresa_mantenedora
    fill_in "Fecha", with: @report.fecha
    fill_in "Inspection", with: @report.inspection_id
    fill_in "Item", with: @report.item_id
    fill_in "Nom tec man", with: @report.nom_tec_man
    fill_in "Tm rut", with: @report.tm_rut
    fill_in "Ul reg man", with: @report.ul_reg_man
    fill_in "Urm fecha", with: @report.urm_fecha
    fill_in "Vi co man ini", with: @report.vi_co_man_ini
    fill_in "Vi co man ter", with: @report.vi_co_man_ter
    click_on "Create Report"

    assert_text "Report was successfully created"
    click_on "Back"
  end

  test "should update Report" do
    visit report_url(@report)
    click_on "Edit this report", match: :first

    fill_in "Certificado minvu", with: @report.certificado_minvu
    fill_in "Ea rol", with: @report.ea_rol
    fill_in "Ea rut", with: @report.ea_rut
    fill_in "Em rol", with: @report.em_rol
    fill_in "Em rut", with: @report.em_rut
    fill_in "Empresa anterior", with: @report.empresa_anterior
    fill_in "Empresa mantenedora", with: @report.empresa_mantenedora
    fill_in "Fecha", with: @report.fecha
    fill_in "Inspection", with: @report.inspection_id
    fill_in "Item", with: @report.item_id
    fill_in "Nom tec man", with: @report.nom_tec_man
    fill_in "Tm rut", with: @report.tm_rut
    fill_in "Ul reg man", with: @report.ul_reg_man
    fill_in "Urm fecha", with: @report.urm_fecha
    fill_in "Vi co man ini", with: @report.vi_co_man_ini
    fill_in "Vi co man ter", with: @report.vi_co_man_ter
    click_on "Update Report"

    assert_text "Report was successfully updated"
    click_on "Back"
  end

  test "should destroy Report" do
    visit report_url(@report)
    click_on "Destroy this report", match: :first

    assert_text "Report was successfully destroyed"
  end
end
