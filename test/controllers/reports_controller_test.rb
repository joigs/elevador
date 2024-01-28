require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @report = reports(:one)
  end

  test "should get index" do
    get reports_url
    assert_response :success
  end

  test "should get new" do
    get new_report_url
    assert_response :success
  end

  test "should create report" do
    assert_difference("Report.count") do
      post reports_url, params: { report: { certificado_minvu: @report.certificado_minvu, ea_rol: @report.ea_rol, ea_rut: @report.ea_rut, em_rol: @report.em_rol, em_rut: @report.em_rut, empresa_anterior: @report.empresa_anterior, empresa_mantenedora: @report.empresa_mantenedora, fecha: @report.fecha, inspection_id: @report.inspection_id, item_id: @report.item_id, nom_tec_man: @report.nom_tec_man, tm_rut: @report.tm_rut, ul_reg_man: @report.ul_reg_man, urm_fecha: @report.urm_fecha, vi_co_man_ini: @report.vi_co_man_ini, vi_co_man_ter: @report.vi_co_man_ter } }
    end

    assert_redirected_to report_url(Report.last)
  end

  test "should show report" do
    get report_url(@report)
    assert_response :success
  end

  test "should get edit" do
    get edit_report_url(@report)
    assert_response :success
  end

  test "should update report" do
    patch report_url(@report), params: { report: { certificado_minvu: @report.certificado_minvu, ea_rol: @report.ea_rol, ea_rut: @report.ea_rut, em_rol: @report.em_rol, em_rut: @report.em_rut, empresa_anterior: @report.empresa_anterior, empresa_mantenedora: @report.empresa_mantenedora, fecha: @report.fecha, inspection_id: @report.inspection_id, item_id: @report.item_id, nom_tec_man: @report.nom_tec_man, tm_rut: @report.tm_rut, ul_reg_man: @report.ul_reg_man, urm_fecha: @report.urm_fecha, vi_co_man_ini: @report.vi_co_man_ini, vi_co_man_ter: @report.vi_co_man_ter } }
    assert_redirected_to report_url(@report)
  end

  test "should destroy report" do
    assert_difference("Report.count", -1) do
      delete report_url(@report)
    end

    assert_redirected_to reports_url
  end
end
